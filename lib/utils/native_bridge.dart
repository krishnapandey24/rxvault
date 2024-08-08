import 'package:flutter/services.dart';

class NativeBridge {
  static const MethodChannel _channel = MethodChannel('com.ensivo/native');

  Future<void> openDownloadFolder() async {
    try {
      await _channel.invokeMethod('openDownloadFolder');
    } on PlatformException catch (e) {
      print("Failed to run native function: '${e.message}'.");
    }
  }
}
