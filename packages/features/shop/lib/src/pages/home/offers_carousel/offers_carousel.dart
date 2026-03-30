import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lt_uicomponent/uicomponent.dart';
import 'package:shop/src/constants/constants.dart';
import 'package:shop/src/pages/home/offers_carousel/banner_style_1.dart';

class OffersCarousel extends StatefulWidget {
  const OffersCarousel({super.key});

  @override
  State<StatefulWidget> createState() => _OffersCarouselState();
}

class _OffersCarouselState extends State<OffersCarousel> {
  int _selectedIndex = 0;
  late PageController _pageController;
  late Timer _timer;
  List offers = [
    BannerStyle1(text: "New items with \nFree shipping", press: () {}),
    Container(height: 50, color: Colors.green),
    Container(height: 50, color: Colors.blue),
  ];

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    // _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
    //   if (_selectedIndex < offers.length - 1) {
    //     _selectedIndex++;
    //   } else {
    //     _selectedIndex = 0;
    //   }
    //   _pageController.animateToPage(
    //     _selectedIndex,
    //     duration: const Duration(milliseconds: 340),
    //     curve: Curves.easeInOut,
    //   );
    // });
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.87,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: offers.length,
            onPageChanged: (value) {
              setState(() {
                _selectedIndex = value;
              });
            },
            itemBuilder: (context, index) => offers[index],
          ),
          FittedBox(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Row(
                children: List.generate(offers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(left: defaultPadding),
                    child: DotIndicator(
                      isActive: index == _selectedIndex,
                      activeColor: Colors.white70,
                      inActiveColor: Colors.white54,
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
