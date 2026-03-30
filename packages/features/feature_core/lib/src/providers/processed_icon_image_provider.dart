import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:lt_uicomponent/uicomponent.dart';
import 'dart:ui' as ui;

import 'package:path_provider/path_provider.dart';

class ProcessedIconImageProvider
    extends ImageProvider<ProcessedIconImageProvider> {
  final String iconId;
  final String imageUrl;
  static String? _cachedTempPath;

  const ProcessedIconImageProvider({
    required this.iconId,
    required this.imageUrl,
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
  int get hashCode => iconId.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProcessedIconImageProvider && other.iconId == iconId;
  }

  Future<ui.Codec> _loadAsync(
    ProcessedIconImageProvider key,
    ImageDecoderCallback decode,
  ) async {
    try {
      final tempPath = _cachedTempPath ?? await _initTempPath();
      final processedFilePath = '${tempPath}/processed_icon+${key.iconId}.png';
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
        final processedBytes = await ImageProcessor.processIcon(originalBytes);
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
}
