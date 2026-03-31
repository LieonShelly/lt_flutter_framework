import 'package:flutter/material.dart';
import 'package:shop/src/pages/home/flash_scale/banner_with_counter.dart';

class FlashScale extends StatelessWidget {
  const FlashScale({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BannerWithCounter(
          text: 'Super Flash Sale \n50% Off',
          duration: const Duration(hours: 8),
          press: () {},
        ),
      ],
    );
  }
}
