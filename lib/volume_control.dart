import 'dart:async';

import 'package:flutter/services.dart';

class VolumeControl {
  static const MethodChannel _channel = const MethodChannel('volume_control');
  static const _volumeEventChannel = EventChannel("volume_change_events");

  static Future<int> setVolume(int level) async {
    final int volumeLevel = await _channel
        .invokeMethod('setVolume', <String, dynamic>{"level": level});
    return volumeLevel;
  }

  static Future<bool> hasAccess() async {
    final initialized = await _channel.invokeMethod("hasAccess");
    return initialized;
  }

  static Future<bool> getAccess() async {
    await _channel.invokeMethod("getAccess");
  }

  static Future<List<int>> getVolumeRange() async {
    final List<dynamic> range = await _channel.invokeMethod("volumeRange");
    return range.map((i) => i as int).toList();
  }

  static Stream<int> get volumeChanges =>
      _volumeEventChannel.receiveBroadcastStream().map((value) => value as int);
}
