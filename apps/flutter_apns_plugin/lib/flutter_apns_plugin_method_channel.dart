import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_apns_plugin_platform_interface.dart';

/// An implementation of [FlutterApnsPluginPlatform] that uses method channels.
class MethodChannelFlutterApnsPlugin extends FlutterApnsPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_apns_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
