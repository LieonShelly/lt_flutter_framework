import 'package:flutter/material.dart';
import 'package:shop/src/pages/home/offers_carousel/banner_style_2.dart';

class BannerSstyle1 extends StatelessWidget {
  const BannerSstyle1({
    super.key,
    this.image = "https://i.imgur.com/K41Mj7C.png",
    required this.title,
    required this.press,
    this.subtitle,
    required this.discountParcent,
  });
  final String? image;
  final String title;
  final String? subtitle;
  final int discountParcent;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return BannerStyle2(
      image: image,
      title: title,
      subTitle: subtitle ?? "",
      press: press,
    );
  }
}
