import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/src/components/cart_button.dart';
import 'package:shop/src/components/network_image_with_loader.dart';
import 'package:shop/src/constants/constants.dart';

class ProductBuyNowScreen extends StatefulWidget {
  const ProductBuyNowScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ProductBuyNowScreenState();
}

class _ProductBuyNowScreenState extends State<ProductBuyNowScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CartButton(price: 123, press: () {}),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: defaultPadding / 2,
              vertical: defaultPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BackButton(),
                Text(
                  'Sleeveless Ruffle',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
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
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1.0,
                  child: NetworkImageWithLoader(
                    url: productDemoImg1,
                    radius: defaultBorderRadious,
                  ),
                ),
                const SizedBox(height: defaultPadding),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: defaultPadding,
                      children: [
                        Text(
                          'Unit Price',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text.rich(
                          TextSpan(
                            text: "\$${123.toStringAsFixed(2)}",
                            style: Theme.of(context).textTheme.titleLarge,
                            children: [
                              TextSpan(
                                text: " \$${222.toStringAsFixed(2)}",
                                style: Theme.of(context).textTheme.titleSmall!
                                    .copyWith(
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: defaultPadding,
                      children: [
                        Text(
                          'Quantity',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),

                        Row(
                          children: [
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.all(
                                    defaultPadding / 2,
                                  ),
                                ),
                                child: SvgPicture.asset(
                                  "assets/icons/Minus.svg",
                                  package: 'shop',
                                  color: Theme.of(context).iconTheme.color,
                                ),
                              ),
                            ),

                            SizedBox(
                              width: 40,
                              child: Center(
                                child: Text(
                                  '3',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),

                            SizedBox(
                              width: 40,
                              height: 40,
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.all(
                                    defaultPadding / 2,
                                  ),
                                ),
                                child: SvgPicture.asset(
                                  "assets/icons/Plus1.svg",
                                  package: 'shop',
                                  color: Theme.of(context).iconTheme.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: defaultPadding * 2),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
