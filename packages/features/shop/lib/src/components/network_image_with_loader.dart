import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lt_uicomponent/uicomponent.dart';

class NetworkImageWithLoader extends StatelessWidget {
  final String url;
  final double radius;
  final BoxFit fit;

  const NetworkImageWithLoader({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.radius = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      child: CachedNetworkImage(
        fit: fit,
        imageUrl: url,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: imageProvider, fit: fit),
          ),
        ),
        placeholder: (context, url) => Skeleton(radius: radius),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }
}
