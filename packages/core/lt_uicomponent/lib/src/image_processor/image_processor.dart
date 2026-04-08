import 'dart:isolate';
import 'dart:typed_data';
import 'ffi_bridge.dart';

class IconParams {
  final String iconId;
  final String imageUrl;
  final int thickness;

  const IconParams({
    required this.iconId,
    required this.imageUrl,
    required this.thickness,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IconParams &&
        other.iconId == iconId &&
        other.thickness == thickness;
  }

  @override
  int get hashCode => iconId.hashCode;
}

class ImageProcessor {
  static Future<Uint8List?> processIcon(
    Uint8List imageBytes,
    int thickness,
  ) async {
    try {
      return await Isolate.run(
        () => FfiBridge.processIcon(imageBytes, thickness),
      );
    } catch (e) {
      print("Failed to process image: '$e'");
      return null;
    }
  }
}
