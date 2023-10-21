try:
    import keyboard
except Exception as e:
    print(f"Exc :{e.__class__}: {e}")
import time
import socket
import json
import threading

GUI_PORT = 33333
KBL_PORT = 33334

# Belgian, Czech, Dutch, English, Estonian, Finnish, French, German, Greek, Hungarian, Italian, Latvian, Lithuanian, Luxembourgish, Romanian, Slovak, Slovenian, Swedish

possibleTranslations: dict = {
    "up": ["up", "haut", "pijl-omhoog", "ylänuoli", "nach-oben", "freccia su", "uppil"],
    "down": ["down", "bas", "pijl-omlaag", "alanuoli", "nach-unten", "freccia giú", "nedpil"],
    "left": ["left", "gauche", "pijl-links", "vasen nuoli", "ncah-links", "freccia sinistra", "vänsterpil"],
    "right": ["right", "droite", "pijl-rechts", "oikea nuoli", "nach-rechts", "freccia destra", "högerpil"],
    "space": ["space", "espace", "spatiebalk", "vali", "leer", "barra spaziatrice", "blanksteg"],
    "shift": ["shift", "maj", "vaihto", "umschalt", "maiusc", "skift"],
    "enter": ["enter", "entree", "vali", "leer", "invio", "retur"],
    "backspace": ["backspace", "ret.arr", "askelpalautin", "rück", "backsteg"],
    "delete": ["delete", "suppr", "del", "entf", "cancella"],
    "end": ["end", "fin", "fine"],
    "home": ["home", "origine", "pos1"]
}


class KeyboardListener:
    def __init__(self):
        self.key_action_map: dict = {}
        self.action_state: dict = {}
        self.do_stream: bool = False
        self.stream_interval_sec = 0.01
        self.timer = None

        # socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
        #         sock_addr = ('127.0.0.1', 8998)  # 172.31.1.148
        #         sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        #         sock.bind(sock_addr)
        #         sock.settimeout(0.0001)

        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.sock.bind(('127.0.0.1', KBL_PORT))
        self.sock.settimeout(0.001)

    def setConfig(self, _key_mapping: dict) -> bool:
        if set(list(_key_mapping.keys())) != {"accel", "brake", "steer_left", "steer_right"}:
            # Invalid setup
            return False
        for action, keys in _key_mapping.items():
            for key in keys:
                if key in possibleTranslations:
                    for translatedKey in possibleTranslations[key]:
                        self.key_action_map[translatedKey] = action
                else:
                    self.key_action_map[key] = action

        keyboard.unhook_all()
        for keys in _key_mapping.values():
            for key in keys:
                if key in possibleTranslations.keys():
                    for translatedKey in possibleTranslations[key]:
                        try:
                            keyboard.on_press_key(translatedKey, self.press)
                            keyboard.on_release_key(translatedKey, self.rel)
                        except ValueError:
                            pass
                else:
                    try:
                        keyboard.on_press_key(key, self.press)
                        keyboard.on_release_key(key, self.rel)
                    except ValueError:
                        pass

        for action in _key_mapping.keys():
            self.action_state[action] = 0
        return True

    def press(self, msg):
        key = msg.__str__().split('(')[-1]
        key = " ".join(key.split(' ')[:-1]).lower()
        try:
            self.action_state[self.key_action_map[key]] = 1
        except KeyError:
            pass

    def rel(self, msg):
        key = msg.__str__().split('(')[-1]
        key = " ".join(key.split(' ')[:-1]).lower()
        try:
            self.action_state[self.key_action_map[key]] = 0
        except KeyError:
            pass

    def send_to_gui(self):
        self.sock.sendto(json.dumps(self.action_state).encode('ascii'), ('127.0.0.1', GUI_PORT))
        self.timer = threading.Timer(kbl.stream_interval_sec, kbl.send_to_gui)
        self.timer.start()

    def run(self):
        while True:
            try:
                data, addr = self.sock.recvfrom(1000)
                msg = json.loads(data.decode('ascii'))
                # print(msg)
                if "msg_type" not in msg.keys():
                    # print("oops")
                    continue
                if msg["msg_type"] == "config":
                    if "data" not in msg.keys():
                        # print("oops")
                        continue
                    if not kbl.setConfig(msg["data"]):
                        print("Invalid config")
                elif msg["msg_type"] == "start":
                    if kbl.timer is not None:
                        kbl.timer.cancel()
                    kbl.timer = threading.Timer(kbl.stream_interval_sec, kbl.send_to_gui)
                    kbl.timer.start()
                elif msg["msg_type"] == "stop":
                    if kbl.timer is not None:
                        kbl.timer.cancel()
                elif msg["msg_type"] == "kill":
                    if kbl.timer is not None:
                        kbl.timer.cancel()
                    raise SystemExit
                else:
                    pass
                    # print("Undefined msg")
            except socket.timeout:
                time.sleep(0.01)
            except ConnectionResetError:
                if kbl.timer is not None:
                    kbl.timer.cancel()
                raise SystemExit
            except Exception:
                if kbl.timer is not None:
                    kbl.timer.cancel()
                raise SystemExit
                # print(f"Big nono {e.__class__}: {e}")


if __name__ == '__main__':
    kbl = KeyboardListener()
    kbl.run()
