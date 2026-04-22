import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_apns_plugin_method_channel.dart';

abstract class FlutterApnsPluginPlatform extends PlatformInterface {
  /// Constructs a FlutterApnsPluginPlatform.
  FlutterApnsPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterApnsPluginPlatform _instance = MethodChannelFlutterApnsPlugin();

  /// The default instance of [FlutterApnsPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterApnsPlugin].
  static FlutterApnsPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterApnsPluginPlatform] when
  /// they register themselves.
  static set instance(FlutterApnsPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
