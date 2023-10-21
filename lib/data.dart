import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:tmuf_kb_helper/globals.dart';
import 'package:tmuf_kb_helper/updateable_valuenotifier.dart';

const AsciiDecoder asciiDecoder = AsciiDecoder();
const AsciiEncoder asciiEncoder = AsciiEncoder();

Map<String, dynamic> configMsg() => {
  "msg_type": "config",
  "data": {
    "accel": Data.keyMappingNotifier.value[ActionType.alternateAccel] == null ? 
      [Data.keyMappingNotifier.value[ActionType.accel]!.name]
      : 
      [Data.keyMappingNotifier.value[ActionType.accel]!.name, Data.keyMappingNotifier.value[ActionType.alternateAccel]!.name],
    "brake": Data.keyMappingNotifier.value[ActionType.alternateBrake] == null ?
      [Data.keyMappingNotifier.value[ActionType.brake]!.name]
      :
      [Data.keyMappingNotifier.value[ActionType.brake]!.name, Data.keyMappingNotifier.value[ActionType.alternateBrake]!.name],
    "steer_left": Data.keyMappingNotifier.value[ActionType.alternateSteerLeft] == null ?
      [Data.keyMappingNotifier.value[ActionType.steerLeft]!.name]
      :
      [Data.keyMappingNotifier.value[ActionType.steerLeft]!.name, Data.keyMappingNotifier.value[ActionType.alternateSteerLeft]!.name],
    "steer_right": Data.keyMappingNotifier.value[ActionType.alternateSteerRight] == null ?
      [Data.keyMappingNotifier.value[ActionType.steerRight]!.name]
      :
      [Data.keyMappingNotifier.value[ActionType.steerRight]!.name, Data.keyMappingNotifier.value[ActionType.alternateSteerRight]!.name],
  }
};

final Map<String, String> startMsg = {
  "msg_type": "start"
};

final Map<String, String> stopMsg = {
  "msg_type": "stop"
};

final Map<String, String> killMsg = {
  "msg_type": "kill"
};

class ActionStatus{
  bool accel = false;
  bool brake = false;
  bool steerLeft = false;
  bool steerRight = false;

  void update(Map statusUpdate){
    accel = statusUpdate["accel"] == 1;
    brake = statusUpdate["brake"] == 1;
    steerLeft = statusUpdate["steer_left"] == 1;
    steerRight = statusUpdate["steer_right"] == 1;
  }
}

enum ActionType{
  accel,
  brake,
  steerLeft,
  steerRight,
  alternateAccel,
  alternateBrake,
  alternateSteerLeft,
  alternateSteerRight
}

extension ToStr on ActionType{
  String get name{
    switch (this) {
      case ActionType.accel:
        return 'Acceleration';
      case ActionType.brake:
        return 'Brake';
      case ActionType.steerLeft:
        return 'Steer left';
      case ActionType.steerRight:
        return 'Steer right';
      case ActionType.alternateAccel:
        return 'Alt accel (Optional)';
      case ActionType.alternateBrake:
        return 'Alt brake (Optional)';
      case ActionType.alternateSteerLeft:
        return 'Alt Steer left (Optional)';
      case ActionType.alternateSteerRight:
        return 'Alt Steer right (Optional)';
    }
  }
}

enum Keys{
  up,
  down,
  left,
  right,
  a,
  b,
  c,
  d,
  e,
  f,
  g,
  h,
  i,
  j,
  k,
  l,
  m,
  n,
  o,
  p,
  q,
  r,
  s,
  t,
  u,
  v,
  w,
  x,
  y,
  z,
  space, //
  shift, //
  tab, //
  enter, //
  backspace, //
  ctrl, ////
  alt, ////
  delete, //
  end, //
  home, //
  insert, ////
}

abstract class Data{
  static late final RawDatagramSocket sock;
  static bool isConfigured = false;
  static bool isStreaming = false;

  static final UpdateableValueNotifier<ActionStatus> statusNotifier = UpdateableValueNotifier<ActionStatus>(ActionStatus());
  static final UpdateableValueNotifier<Map<ActionType, Keys>> keyMappingNotifier = UpdateableValueNotifier<Map<ActionType, Keys>>({});

  static void updateKeyMapping(ActionType action, Keys key, {final bool sendUpdate = true}){
    keyMappingNotifier.update((keyMapping) {
      if(!keyMapping.containsKey(action)){
        keyMapping[action] = key;
      }
      else{
        Keys prevKey = keyMapping.remove(action)!;
        if(keyMapping.values.contains(key)){
          ActionType otherAction = keyMapping.keys.firstWhere((action) => keyMapping[action] == key);
          keyMapping[otherAction] = prevKey;
          keyMapping[action] = key;
        }
        else{
          keyMapping[action] = key;
        }
      }
      if(sendUpdate){
        configure();
      }
    });
  }

  static Future<void> init() async {
    sock = await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, guiPort);
    sock.listen((event) {
      if (event == RawSocketEvent.read) {
        Uint8List? udpPayload = sock.receive()?.data;
        if (udpPayload != null && udpPayload.isNotEmpty) {
          Map statusUpdate = jsonDecode(asciiDecoder.convert(udpPayload));
          if(!__validateStatus(statusUpdate)){
            showError(topLevelContext, "Sth is wrong with the kb listener");
          }
          else{
            statusNotifier.update((value) {
              value.update(statusUpdate);
            });
          }
        }
      }
    });
    await Future.delayed(const Duration(milliseconds: 1000));
    if(configure()){
      await Future.delayed(const Duration(milliseconds: 100));
      send(startMsg);
    }
  }

  static void send(Map<String, dynamic> msg){
    if(msg["msg_type"] == "stop"){
      isStreaming = false;
    }
    else if(msg["msg_type"] == "start"){
      isStreaming = true;
    }
    sock.send(asciiEncoder.convert(jsonEncode(msg)), InternetAddress.loopbackIPv4, kblPort);
  }

  static bool __validateStatus(Map statusUpdate){
    List<String> keysToCheck = ["accel", "brake", "steer_left", "steer_right"];
    bool success = keysToCheck.every((element) => statusUpdate.keys.contains(element));
    // etc
    return success;
  }

  static bool __validateKeyMapping(Map keyMapping){
    bool success = [ActionType.accel, ActionType.brake, ActionType.steerLeft, ActionType.steerRight].every((element) => keyMapping.keys.contains(element));
    // etc
    return success;
  }

  static bool configure(){
    if(__validateKeyMapping(keyMappingNotifier.value)){
        send(configMsg());
        isConfigured = true;
        return true;
    }
    return false;
  }
}


  