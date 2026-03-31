import 'package:flutter/material.dart';
import 'package:shop/shop.dart';
import 'package:shop/src/constants/constants.dart';
import 'package:shop/src/pages/home/best_seller/banner_sstyle1.dart';
import 'package:shop/src/pages/home/popular_products/product_card.dart';
import 'package:shop/src/pages/home/popular_products/product_model.dart';

class BestSeller extends StatelessWidget {
  const BestSeller({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BannerSstyle1(
          title: "New \narrival",
          subtitle: "SPECIAL OFFER",
          discountParcent: 50,
          press: () {
            Navigator.pushNamed(context, onSaleScreenRoute);
          },
        ),

        Padding(
          padding: const EdgeInsets.only(
            left: defaultPadding,
            top: defaultPadding,
            bottom: defaultPadding,
          ),
          child: Text(
            "Best Seller",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),

        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: demoFlashSaleProducts.length,
            itemBuilder: (context, index) {
              final product = demoFlashSaleProducts[index];

              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? defaultPadding : 0,
                  right: defaultPadding,
                ),
                child: ProductCard(
                  image: product.image,
                  brandName: product.brandName,
                  title: product.title,
                  price: product.price,
                  press: () {},
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
