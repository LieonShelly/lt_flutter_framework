import 'package:flutter/material.dart';
import 'package:shop/src/constants/constants.dart';
import 'package:shop/src/pages/home/offers_carousel/bannerm.dart';

class BannerStyle1 extends StatelessWidget {
  final String? image;
  final String text;
  final VoidCallback press;

  const BannerStyle1({
    super.key,
    this.image = "https://i.imgur.com/UP7xhPG.png",
    required this.text,
    required this.press,
  });

  @override
  Widget build(BuildContext context) {
    return BannerM(
      image: image!,
      press: press,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: grandisExtendedFont,
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                ),
              ),
              const Text(
                'Shop now',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(
                width: 64,
                child: Divider(color: Colors.white, thickness: 2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
