import 'package:flutter/material.dart';
import 'package:shop/src/components/network_image_with_loader.dart';
import 'package:shop/src/constants/constants.dart';
import 'package:shop/src/pages/home/popular_products/product_card.dart';
import 'package:shop/src/pages/home/popular_products/product_model.dart';

class PopularProducts extends StatelessWidget {
  const PopularProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: defaultPadding,
            top: defaultPadding,
          ),
          child: Text(
            'Popular products',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: defaultPadding),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: demoPopularProducts.length,
            itemBuilder: (context, index) {
              final product = demoPopularProducts[index];
              final isFirstItem = index == 0;
              return Padding(
                padding: EdgeInsets.only(
                  left: isFirstItem ? defaultPadding : 0,
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
