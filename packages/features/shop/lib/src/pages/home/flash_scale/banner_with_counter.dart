import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shop/src/constants/constants.dart';
import 'package:shop/src/pages/home/offers_carousel/bannerm.dart';

class BannerWithCounter extends StatefulWidget {
  final String image, text;
  final Duration duration;
  final VoidCallback press;

  const BannerWithCounter({
    super.key,
    this.image = 'https://i.imgur.com/pRgcbpS.png',
    required this.text,
    required this.duration,
    required this.press,
  });

  @override
  State<StatefulWidget> createState() => _BannerWithCounterState();
}

class _BannerWithCounterState extends State<BannerWithCounter> {
  late Duration _duration;
  late Timer _timer;

  @override
  void initState() {
    _duration = widget.duration;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _duration = Duration(seconds: _duration.inSeconds - 1);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BannerM(
      image: widget.image,
      press: widget.press,
      children: [
        Align(
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: grandisExtendedFont,
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
