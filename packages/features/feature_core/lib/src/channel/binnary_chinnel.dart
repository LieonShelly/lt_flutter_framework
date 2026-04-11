import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class BinaryChannelService {
  static const BasicMessageChannel<ByteData> _binaryChannel =
      BasicMessageChannel<ByteData>('binnary_channel', BinaryCodec());

  static void initReceiver() {
    _binaryChannel.setMessageHandler((ByteData? message) async {
      if (message != null) {}
      return ByteData(0);
    });
  }

  static Future<void> sendBinaryData(Uint8List data) async {
    ByteData byteData = ByteData.sublistView(data);
    try {
      ByteData? reply = await _binaryChannel.send(byteData);
      if (reply != null) {
        print('收到 Native 的处理回执, ${reply.lengthInBytes} bytes');
      }
    } on PlatformException catch (e) {
      print("发送二进制数据失败: ${e.message}");
    }
  }
}
