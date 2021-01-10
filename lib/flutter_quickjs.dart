
import 'dart:async';

import 'package:flutter/services.dart';

class FlutterQuickjs {
  static const MethodChannel _channel =
      const MethodChannel('flutter_quickjs');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
