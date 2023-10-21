import 'dart:convert';
import 'dart:io';

import 'package:tmuf_kb_helper/data.dart';

String? _currentDirectory;

Future<String> get getCurrentDirectory async {  // dam this is waytoodank
  if(_currentDirectory != null){
    return _currentDirectory!;
  }
  String dir = Platform.resolvedExecutable;
  dir = dir.replaceAll(r'\', '/');
  dir = dir.split('/').reversed.toList().sublist(1).reversed.toList().join('/');
  dir = dir.replaceAll('/', r'\');
  dir = dir + r'\';
  _currentDirectory = dir;
  return dir;
}

Future<void> startListener() async {
  ProcessResult res = await Process.run("netstat", ["-ano"]);
  List<String> relevantLines = res.stdout.toString().split('\n').where((element){return element.contains(":33334") && element.contains('UDP');}).toList();
  List<String> pids = relevantLines.map((e) => e.split(' ').last,).toList();
  for(String pid in pids){
    ProcessResult res = await Process.run("taskkill", ["/PID", pid.substring(0, pid.length - 1), "/F"]);
  }
  Process.run("${await getCurrentDirectory}kblistener.exe", [],);
}

Future<void> saveSettings() async {
  File settingFile = File("${await getCurrentDirectory}settings.json");
  if(!await settingFile.exists()){
    settingFile.create(recursive: true);
  }
  Map<String,String> jsonEncodeable = Data.keyMappingNotifier.value.map((key, value) => MapEntry(key.name, value.name));
  await settingFile.writeAsBytes(asciiEncoder.convert(jsonEncode(jsonEncodeable)));
}

Future<void> loadSettings() async {
  File settingFile = File("${await getCurrentDirectory}settings.json");
  if(await settingFile.exists()){
    Map<String,dynamic> jsonDecoded = jsonDecode(asciiDecoder.convert(await settingFile.readAsBytes()));
    Map<ActionType, Keys> keyMappingLoaded = jsonDecoded.map((key, value) => MapEntry(
      ActionType.values.firstWhere((element) => element.name == key),
      Keys.values.firstWhere((element) => element.name == value)));

    for(ActionType action in keyMappingLoaded.keys){
      Data.updateKeyMapping(action, keyMappingLoaded[action]!, sendUpdate: false);
    }
  }
}
