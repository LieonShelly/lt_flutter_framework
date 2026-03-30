import 'package:flutter/material.dart';
import 'package:shop/src/components/network_image_with_loader.dart';

class BannerM extends StatelessWidget {
  final List<Widget> children;
  final String image;
  final VoidCallback press;

  const BannerM({
    super.key,
    required this.image,
    required this.press,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.87,
      child: GestureDetector(
        onTap: press,
        child: Stack(
          children: [
            NetworkImageWithLoader(url: image),
            Container(decoration: BoxDecoration(color: Colors.black45)),
            ...children,
          ],
        ),
      ),
    );
  }
}
