import 'dart:async';

import 'package:flutter/material.dart';
import 'package:volume_control/volume_control.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _hasAccess = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future initialize() async {
    _hasAccess = await VolumeControl.hasAccess();
    setState(() {});
  }

  // Platform messages are asynchronous, so we initialize in an async method.
//  Future<void> increaseVolume() async {
//    int volume;
//    // Platform messages may fail, so we use a try/catch PlatformException.
//    try {
//      volume = await VolumeControl.setVolume(_currentVolume + 1);
//    } on PlatformException {
//      volume = _currentVolume;
//    }
//
//    // If the widget was removed from the tree while the asynchronous platform
//    // message was in flight, we want to discard the reply rather than calling
//    // setState to update our non-existent appearance.
//    if (!mounted) return;
//
//    setState(() {
//      _currentVolume = volume;
//    });
//  }

  void _grantAccess() {
    VolumeControl.getAccess();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: FutureBuilder(
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData) {
                return snapshot.data
                    ? FutureBuilder(
                        future: VolumeControl.getVolumeRange(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<int>> snapshot) {
                          if (snapshot.hasData) {
                            return VolumeControlDisplay(
                                maxVolume: snapshot.data[1]);
                          } else {
                            return Text("Loading Volume Info");
                          }
                        },
                      )
                    : Column(children: <Widget>[
                        Text("No Access"),
                        RaisedButton(
                          onPressed: () {
                            _grantAccess();
                          },
                          child: Text("Grant Access"),
                        ),
                      ]);
              } else {
                return Container();
              }
            },
            future: VolumeControl.hasAccess(),
          )),
    );
  }
}

class VolumeControlDisplay extends StatefulWidget {
  final int maxVolume;

  const VolumeControlDisplay({Key key, @required this.maxVolume})
      : super(key: key);

  @override
  VolumeControlDisplayState createState() {
    return new VolumeControlDisplayState();
  }
}

class VolumeControlDisplayState extends State<VolumeControlDisplay> {

  void _setVolume(int value) async {
    await VolumeControl.setVolume(value.toInt());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Listening for volume…");
        } else if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            var currentVolume = snapshot.data;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("Current Volume: $currentVolume"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      child: Text("-"),
                      onPressed: () {
                        _setVolume(currentVolume-1);
                      },
                    ),
                    RaisedButton(
                      child: Text("+"),
                      onPressed: () {
                        _setVolume(currentVolume+1);
                      },
                    )
                  ],
                ),
              ],
            );
          }
        }
        return Text("Current Volume unknown");
      },
      initialData: 0,
      stream: VolumeControl.volumeChanges,
    );
  }
}
