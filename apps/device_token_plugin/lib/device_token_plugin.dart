
import 'device_token_plugin_platform_interface.dart';

class DeviceTokenPlugin {
  Future<String?> getPlatformVersion() {
    return DeviceTokenPluginPlatform.instance.getPlatformVersion();
  }
}
