import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lt_uicomponent/uicomponent.dart';
import 'package:feature_core/feature_core.dart';

class ProcessedIconView extends ConsumerWidget with ImageCacheKeyType {
  final String imageUrl;
  final double? width;
  final double? height;
  final Widget placeholder;
  final String herTag;
  final VoidCallback? onImageLoaded;

  const ProcessedIconView({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    required this.placeholder,
    required this.herTag,
    this.onImageLoaded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (imageUrl.isEmpty) return _buildPlaceholder();
    return Hero(
      tag: herTag,
      child: Image(
        image: ProcessedIconImageProvider(
          iconId: cacheKey(imageUrl),
          imageUrl: imageUrl,
        ),
        width: width,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _buildPlaceholder(),
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) return child;
          return _buildPlaceholder();
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return SizedBox(width: width, height: height ?? 100.0, child: placeholder);
  }
}
