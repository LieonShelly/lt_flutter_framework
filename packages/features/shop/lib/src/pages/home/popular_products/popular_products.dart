import 'package:flutter/material.dart';
import 'package:shop/src/components/network_image_with_loader.dart';
import 'package:shop/src/constants/constants.dart';
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
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(140, 220),
                    maximumSize: const Size(140, 220),
                    padding: const EdgeInsets.all(8),
                  ),
                  child: Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 1.15,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            NetworkImageWithLoader(
                              url: product.image,
                              radius: defaultBorderRadious,
                            ),
                            if (product.dicountpercent != null)
                              Positioned(
                                top: defaultPadding / 2,
                                right: defaultPadding / 2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: defaultPadding / 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: errorColor,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(defaultBorderRadious),
                                    ),
                                  ),
                                  child: Text(
                                    '${product.dicountpercent}% off',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: defaultPadding / 2,
                            vertical: defaultPadding / 2,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.brandName.toUpperCase(),
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium!.copyWith(fontSize: 10),
                              ),
                              const SizedBox(height: defaultPadding / 2),
                              Text(
                                product.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleSmall!.copyWith(fontSize: 12),
                              ),
                              const Spacer(),
                              product.priceAfetDiscount != null
                                  ? Row(
                                      children: [
                                        Text(
                                          "\$${product.priceAfetDiscount}",
                                          style: const TextStyle(
                                            color: Color(0xFF31B0D8),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          "\$${product.price}",
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium!.color,
                                            fontSize: 10,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      "\$${product.price}",
                                      style: const TextStyle(
                                        color: Color(0xFF31B0D8),
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
