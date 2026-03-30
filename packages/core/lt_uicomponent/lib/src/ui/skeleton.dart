import 'package:flutter/material.dart';

class Skeleton extends StatelessWidget {
  final double? height, width;
  final int layer;
  final double radius;

  const Skeleton({
    super.key,
    this.height,
    this.width,
    this.layer = 1,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(16 / 2),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
    );
  }
}
