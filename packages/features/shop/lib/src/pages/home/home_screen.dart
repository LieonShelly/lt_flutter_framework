import 'package:flutter/material.dart';
import 'package:shop/shop.dart';
import 'package:shop/src/constants/constants.dart';
import 'package:shop/src/pages/home/best_seller/best_seller.dart';
import 'package:shop/src/pages/home/categories/categories.dart';
import 'package:shop/src/pages/home/flash_scale/flash_scale.dart';
import 'package:shop/src/pages/home/most_popular/most_popular.dart';
import 'package:shop/src/pages/home/offers_carousel/banner_style_3.dart';
import 'package:shop/src/pages/home/offers_carousel/offers_carousel.dart';
import 'package:shop/src/pages/home/popular_products/popular_products.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: OffersCarousel()),
            const SliverToBoxAdapter(child: Categories()),
            const SliverToBoxAdapter(child: PopularProducts()),
            const SliverPadding(
              padding: EdgeInsets.symmetric(vertical: defaultPadding * 0),
              sliver: SliverToBoxAdapter(child: FlashScale()),
            ),
            const SliverToBoxAdapter(child: BestSeller()),
            SliverPadding(
              padding: EdgeInsets.symmetric(vertical: defaultPadding * 1.5),
              sliver: SliverToBoxAdapter(
                child: BannerStyle3(
                  image: 'https://i.imgur.com/wQ0sNHT.png',
                  title: 'Black \nfriday',
                  press: () {
                    Navigator.pushNamed(context, onSaleScreenRoute);
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: MostPopular()),
          ],
        ),
      ),
    );
  }
}
