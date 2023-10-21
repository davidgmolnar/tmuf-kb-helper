import 'package:flutter/material.dart';
import 'package:tmuf_kb_helper/components/appbar.dart';
import 'package:tmuf_kb_helper/data.dart';
import 'package:tmuf_kb_helper/globals.dart';
import 'package:tmuf_kb_helper/main.dart';
import 'package:window_manager/window_manager.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    windowManager.setSize(settingsSize);
    windowManager.setResizable(false);
    return Scaffold(
      body: Column(
        children: const [
          CustomAppBar(),
          Expanded(child: SettingsBody()),
        ],
      ),
    );
  }
}

class SettingsBody extends StatefulWidget {
  const SettingsBody({super.key});

  @override
  State<SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<SettingsBody> {
  @override
  void initState() {
    Data.keyMappingNotifier.addListener(update);
    super.initState();
  }

  void update() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(
          height: ActionType.values.length * 50,
          child: ListView.builder(
            itemCount: ActionType.values.length,
            itemExtent: 50,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: ((context, index) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 230,
                    padding: defaultPadding,
                    child: Text("${ActionType.values[index].name} key:", style: textStyle,),
                  ),
                  DropdownButton<Keys>(
                    key: UniqueKey(),
                    value: Data.keyMappingNotifier.value[ActionType.values[index]],
                    items: Keys.values.map((e) => DropdownMenuItem<Keys>(value: e, child: Text(e.name, style: textStyle,),)).toList()..add(const DropdownMenuItem(value: null, child: Text("Please select", style: textStyle,))),
                    onChanged: ((value) {
                      if(value == null){
                        return;
                      }
                      Data.updateKeyMapping(ActionType.values[index], value);
                    })
                  ),
                ]
              );
            })
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                if(!Data.configure()){
                  showError(context, "Incomplete configuration");
                }
              },
              child: const Text("Apply", style: textStyle,)
            ),
            Data.isStreaming ? 
              TextButton(
                onPressed: () {
                  Data.send(stopMsg);
                  setState(() {});
                },
                child: const Text("Stop", style: textStyle,)
              )
              :
              TextButton(
                onPressed: () {                  
                  if(Data.isConfigured){
                    Data.send(startMsg);
                    setState(() {});
                  }
                  else{
                    showError(context, "Configure first");
                  }
                },
                child: const Text("Start", style: textStyle,)
              )
          ],
        ),
      ]
    );
  }

  @override
  void dispose() {
    Data.keyMappingNotifier.removeListener(update);
    super.dispose();
  }
}