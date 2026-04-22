import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_apns_plugin/flutter_apns_plugin.dart';
import 'package:flutter_apns_plugin/flutter_apns_plugin_platform_interface.dart';
import 'package:flutter_apns_plugin/flutter_apns_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterApnsPluginPlatform
    with MockPlatformInterfaceMixin
    implements FlutterApnsPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterApnsPluginPlatform initialPlatform = FlutterApnsPluginPlatform.instance;

  test('$MethodChannelFlutterApnsPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterApnsPlugin>());
  });

  test('getPlatformVersion', () async {
    FlutterApnsPlugin flutterApnsPlugin = FlutterApnsPlugin();
    MockFlutterApnsPluginPlatform fakePlatform = MockFlutterApnsPluginPlatform();
    FlutterApnsPluginPlatform.instance = fakePlatform;

    expect(await flutterApnsPlugin.getPlatformVersion(), '42');
  });
}
