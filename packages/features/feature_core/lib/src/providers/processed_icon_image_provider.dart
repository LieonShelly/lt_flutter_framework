import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:lt_uicomponent/uicomponent.dart';
import 'dart:ui' as ui;

import 'package:path_provider/path_provider.dart';

class ProcessedIconImageProvider
    extends ImageProvider<ProcessedIconImageProvider> {
  final String iconId;
  final String imageUrl;
  final int thickness;

  static String? _cachedTempPath;

  const ProcessedIconImageProvider({
    required this.iconId,
    required this.imageUrl,
    required this.thickness,
  });

  @override
  Future<ProcessedIconImageProvider> obtainKey(
    ImageConfiguration configuration,
  ) {
    return SynchronousFuture(this);
  }

  @override
  ImageStreamCompleter loadImage(
    ProcessedIconImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
    );
  }

  @override
  int get hashCode => Object.hash(iconId, thickness);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProcessedIconImageProvider &&
        other.iconId == iconId &&
        other.thickness == thickness;
  }

  Future<ui.Codec> _loadAsync(
    ProcessedIconImageProvider key,
    ImageDecoderCallback decode,
  ) async {
    try {
      final tempPath = _cachedTempPath ?? await _initTempPath();
      final processedFilePath =
          '${tempPath}/processed_icon+${key.iconId}+thicness${thickness}.png';
      final processedFile = File(processedFilePath);
      Uint8List bytes;
      if (await processedFile.exists()) {
        bytes = await processedFile.readAsBytes();
      } else {
        final file = await DefaultCacheManager().getSingleFile(
          key.imageUrl,
          key: key.iconId,
        );
        final originalBytes = await file.readAsBytes();
        final processedBytes = await ImageProcessor.processIcon(
          originalBytes,
          thickness,
        );
        if (processedBytes == null || processedBytes.isEmpty) {
          throw Exception('Failed to process icon: ${key.iconId}');
        }
        await processedFile.writeAsBytes(processedBytes);
        bytes = processedBytes;
      }
      final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      return decode(buffer);
    } catch (e) {
      throw Exception('ProcessedIconImageProvider error [${key.iconId}]: $e');
    }
  }

  static Future<String> _initTempPath() async {
    final dir = await getTemporaryDirectory();
    _cachedTempPath = dir.path;
    return dir.path;
  }

  /// 获取处理后的图标缓存文件路径
  static Future<String?> getCachedFilePath({
    required String imageUrl,
    required int thickness,
  }) async {
    final cacheKey = ImageCacheKey().cacheKey(imageUrl);
    final tempPath = _cachedTempPath ?? await _initTempPath();
    final path = '$tempPath/processed_icon+$cacheKey+thicness$thickness.png';
    final file = File(path);
    if (await file.exists()) {
      return path;
    }
    return null;
  }
}

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
