import 'package:flutter/material.dart';
import 'package:shop/src/pages/home/offers_carousel/offers_carousel.dart';

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
          slivers: [SliverToBoxAdapter(child: OffersCarousel())],
        ),
      ),
    );
  }
}
