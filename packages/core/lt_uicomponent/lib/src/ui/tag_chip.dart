import 'package:lt_uicomponent/uicomponent.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class TagChip extends StatelessWidget {
  final String tag;
  final double fontSize;
  final double height;
  final Color? chipColor;
  final Color? onChipColor;

  const TagChip({
    super.key,
    required this.tag,
    this.fontSize = 10,
    this.height = 20,
    this.chipColor,
    this.onChipColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: chipColor ?? AppColors.whiteTransparent,
          ),
          child: SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _iconFrom(tag),
                    color: onChipColor ?? Colors.white,
                    size: fontSize,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    tag,
                    textAlign: TextAlign.center,
                    style: _textStyle(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData? _iconFrom(String tag) {
    return switch (tag) {
      'Adventure sports' => Icons.kayaking_outlined,
      'Beach' => Icons.beach_access_outlined,
      'City' => Icons.location_city_outlined,
      'Cultural experiences' => Icons.museum_outlined,
      'Foodie' || 'Food tours' => Icons.restaurant,
      'Hiking' => Icons.hiking,
      'Historic' => Icons.menu_book_outlined,
      'Island' || 'Coastal' || 'Lake' || 'River' => Icons.water,
      'Luxury' => Icons.attach_money_outlined,
      'Mountain' || 'Wildlife watching' => Icons.landscape_outlined,
      'Nightlife' => Icons.local_bar_outlined,
      'Off-the-beaten-path' => Icons.do_not_step_outlined,
      'Romantic' => Icons.favorite_border_outlined,
      'Rural' => Icons.agriculture_outlined,
      'Secluded' => Icons.church_outlined,
      'Sightseeing' => Icons.attractions_outlined,
      'Skiing' => Icons.downhill_skiing_outlined,
      'Wine tasting' => Icons.wine_bar_outlined,
      'Winter destination' => Icons.ac_unit,
      _ => Icons.label_outlined,
    };
  }

  // Note: original Figma file uses Google Sans
  // which is not available on GoogleFonts
  TextStyle _textStyle(BuildContext context) => GoogleFonts.openSans(
    textStyle: TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: fontSize,
      color: onChipColor ?? Colors.white,
      textBaseline: TextBaseline.alphabetic,
    ),
  );
}
