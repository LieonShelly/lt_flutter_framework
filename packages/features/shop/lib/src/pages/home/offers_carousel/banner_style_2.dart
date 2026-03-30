import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop/src/constants/constants.dart';
import 'package:shop/src/pages/home/offers_carousel/bannerm.dart';

class BannerStyle2 extends StatelessWidget {
  final String? image;
  final String title;
  final String subTitle;
  final VoidCallback press;

  const BannerStyle2({
    super.key,
    this.image = "https://i.imgur.com/J1Qjut7.png",
    required this.title,
    required this.subTitle,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: grandisExtendedFont,
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                    ),
                  ),

                  Text(
                    subTitle.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              SizedBox(
                width: 48,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: Colors.white,
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/Arrow - Right.svg',
                    package: 'shop',
                    colorFilter: const ColorFilter.mode(
                      Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Align(
          alignment: Alignment.topCenter,
          child: BannerDiscountTag(percentage: 50),
        ),
      ],
    );
  }
}

class BannerDiscountTag extends StatelessWidget {
  const BannerDiscountTag({
    super.key,
    this.width = 36,
    this.height = 60,
    required this.percentage,
    this.percentageFontSize = 10,
  });
  final double width, height;
  final int percentage;
  final double percentageFontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            "assets/icons/Discount_tag.svg",
            package: 'shop',
            fit: BoxFit.fill,
            colorFilter: const ColorFilter.mode(
              Colors.white70,
              BlendMode.srcIn,
            ),
          ),
          Text(
            '$percentage%\noff',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: grandisExtendedFont,
              color: Colors.black54,
              fontSize: percentageFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
