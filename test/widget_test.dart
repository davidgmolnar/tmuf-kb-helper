import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

const int GUI_PORT = 33333;
const int KBL_PORT = 33334;

void main() async {
  const AsciiDecoder asciiDecoder = AsciiDecoder();
  const AsciiEncoder asciiEncoder = AsciiEncoder();

  RawDatagramSocket sock = await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, GUI_PORT);
  sock.listen((event) {
    if (event == RawSocketEvent.read) {
      Uint8List? udpPayload = sock.receive()?.data;
      if (udpPayload != null && udpPayload.isNotEmpty) {
        print(asciiDecoder.convert(udpPayload));
      }
    }
  });

  Map configMsg = {
    "msg_type": "config",
    "data": {
      "accel": "up",
      "brake": "down",
      "steer_left": "left",
      "steer_right": "right"
    }
  };

  Map configMsg2 = {
    "msg_type": "config",
    "data": {
      "accel": "t",
      "brake": "g",
      "steer_left": "f",
      "steer_right": "h"
    }
  };

  Map startMsg = {
    "msg_type": "start"
  };

  Map stopMsg = {
    "msg_type": "stop"
  };

  Map killMsg = {
    "msg_type": "kill"
  };

  int cnt = 0;
  while(cnt <= 30){
    print(cnt);
    if(cnt == 0){
      sock.send(asciiEncoder.convert(jsonEncode(configMsg)), InternetAddress.loopbackIPv4, KBL_PORT);
    }
    if(cnt == 1){
      sock.send(asciiEncoder.convert(jsonEncode(startMsg)), InternetAddress.loopbackIPv4, KBL_PORT);
    }
    if(cnt == 10){
      sock.send(asciiEncoder.convert(jsonEncode(configMsg2)), InternetAddress.loopbackIPv4, KBL_PORT);
    }
    if(cnt == 20){
      sock.send(asciiEncoder.convert(jsonEncode(stopMsg)), InternetAddress.loopbackIPv4, KBL_PORT);
    }
    if(cnt == 30){
      sock.send(asciiEncoder.convert(jsonEncode(killMsg)), InternetAddress.loopbackIPv4, KBL_PORT);
    }
    cnt++;
    await Future.delayed(Duration(seconds: 1));
  }
}
