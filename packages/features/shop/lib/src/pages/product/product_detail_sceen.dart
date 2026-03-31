import 'package:flutter/material.dart';
import 'package:shop/src/components/cart_button.dart';

class ProductDetailSceen extends StatelessWidget {
  final bool isProductAvailable;

  const ProductDetailSceen({super.key, this.isProductAvailable = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CartButton(price: 140, press: () {}),
      body: SafeArea(child: SizedBox()),
    );
  }
}
