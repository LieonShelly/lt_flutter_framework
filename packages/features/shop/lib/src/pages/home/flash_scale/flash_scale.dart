import 'package:flutter/material.dart';
import 'package:shop/src/constants/constants.dart';
import 'package:shop/src/pages/home/flash_scale/banner_with_counter.dart';
import 'package:shop/src/components/product_card.dart';
import 'package:shop/src/pages/home/popular_products/product_model.dart';

class FlashScale extends StatelessWidget {
  const FlashScale({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BannerWithCounter(
          text: 'Super Flash Sale \n50% Off',
          duration: const Duration(hours: 8),
          press: () {},
        ),

        Padding(
          padding: const EdgeInsets.only(
            left: defaultPadding,
            top: defaultPadding,
            bottom: defaultPadding,
          ),
          child: Text(
            "Flash scale",
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
