import 'package:flutter/material.dart';

class ImageErrorWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final double iconSize;

  const ImageErrorWidget({
    super.key,
    this.width,
    this.height,
    this.iconSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey,
          size: iconSize,
        ),
      ),
    );
  }
}

class ImagePlaceholderWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final double indicatorSize;

  const ImagePlaceholderWidget({
    super.key,
    this.width,
    this.height,
    this.indicatorSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Center(
        child: SizedBox(
          width: indicatorSize,
          height: indicatorSize,
          child: CircularProgressIndicator(
            strokeWidth: indicatorSize > 20 ? 3 : 2,
          ),
        ),
      ),
    );
  }
}
