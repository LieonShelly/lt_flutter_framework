import 'package:flutter/material.dart';
import 'package:shop/src/constants/constants.dart';
import 'package:shop/src/components/product_card.dart';
import 'package:shop/src/pages/home/popular_products/product_model.dart';

class MostPopular extends StatelessWidget {
  const MostPopular({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: defaultPadding,
            top: defaultPadding,
            bottom: defaultPadding,
          ),
          child: Text(
            "Most popular",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),

        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: demoPopularProducts.length,
            itemBuilder: (context, index) {
              final product = demoPopularProducts[index];

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
