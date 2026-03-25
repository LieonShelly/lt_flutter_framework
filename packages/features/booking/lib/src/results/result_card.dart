import 'package:booking_domain/booking_domain.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lt_uicomponent/uicomponent.dart';

class ResultCard extends StatelessWidget {
  final Destination destination;
  final GestureTapCallback onTap;

  const ResultCard({super.key, required this.destination, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: destination.imageUrl,
            fit: BoxFit.fitHeight,
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.image_not_supported_outlined),
              ),
            ),
            placeholder: (context, url) => Container(
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(destination.name.toUpperCase(), style: _cardTitleStyle),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4.0,
                  runSpacing: 4.0,
                  direction: Axis.horizontal,
                  children: destination.tags
                      .map((e) => TagChip(tag: e))
                      .toList(),
                ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(onTap: onTap),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final _cardTitleStyle = GoogleFonts.rubik(
  textStyle: const TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: 15.0,
    color: Colors.white,
    letterSpacing: 1,
    shadows: [
      // Helps to read the text a bit better
      Shadow(blurRadius: 3.0, color: Colors.black),
    ],
  ),
);
