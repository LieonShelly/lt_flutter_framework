import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop/src/components/cart_button.dart';
import 'package:shop/src/components/notify_me_card.dart';
import 'package:shop/src/constants/constants.dart';
import 'package:shop/src/pages/product/product_images.dart';
import 'package:shop/src/pages/product/product_info.dart';

class ProductDetailSceen extends StatelessWidget {
  final bool isProductAvailable;

  const ProductDetailSceen({super.key, this.isProductAvailable = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: isProductAvailable
          ? CartButton(price: 140, press: () {})
          : NotifyMeCard(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              floating: true,
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(
                    'assets/icons/Bookmark.svg',
                    package: 'shop',
                    color: Theme.of(context).textTheme!.bodyLarge!.color,
                  ),
                ),
              ],
            ),
            ProductImages(
              images: [productDemoImg1, productDemoImg2, productDemoImg3],
            ),
            const ProductInfo(),
          ],
        ),
      ),
    );
  }
}
