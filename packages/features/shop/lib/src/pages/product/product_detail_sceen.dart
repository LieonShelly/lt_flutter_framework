import 'package:flutter/material.dart';
import 'package:shop/src/components/cart_button.dart';
import 'package:shop/src/components/notify_me_card.dart';

class ProductDetailSceen extends StatelessWidget {
  final bool isProductAvailable;

  const ProductDetailSceen({super.key, this.isProductAvailable = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: isProductAvailable
          ? CartButton(price: 140, press: () {})
          : NotifyMeCard(),
      body: SafeArea(child: SizedBox()),
    );
  }
}
