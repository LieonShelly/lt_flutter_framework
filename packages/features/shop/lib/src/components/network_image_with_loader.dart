import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lt_uicomponent/uicomponent.dart';

class NetworkImageWithLoader extends StatelessWidget {
  final String url;
  final double radius;

  const NetworkImageWithLoader({super.key, required this.url, this.radius = 0});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      child: CachedNetworkImage(
        fit: BoxFit.cover,
        imageUrl: url,
        placeholder: (context, url) => Skeleton(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }
}
