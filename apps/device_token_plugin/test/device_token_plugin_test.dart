import 'package:flutter_test/flutter_test.dart';
import 'package:device_token_plugin/device_token_plugin.dart';
import 'package:device_token_plugin/device_token_plugin_platform_interface.dart';
import 'package:device_token_plugin/device_token_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDeviceTokenPluginPlatform
    with MockPlatformInterfaceMixin
    implements DeviceTokenPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final DeviceTokenPluginPlatform initialPlatform = DeviceTokenPluginPlatform.instance;

  test('$MethodChannelDeviceTokenPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDeviceTokenPlugin>());
  });

  test('getPlatformVersion', () async {
    DeviceTokenPlugin deviceTokenPlugin = DeviceTokenPlugin();
    MockDeviceTokenPluginPlatform fakePlatform = MockDeviceTokenPluginPlatform();
    DeviceTokenPluginPlatform.instance = fakePlatform;

    expect(await deviceTokenPlugin.getPlatformVersion(), '42');
  });
}
