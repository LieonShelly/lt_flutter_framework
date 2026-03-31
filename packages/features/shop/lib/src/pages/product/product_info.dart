import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop/src/constants/constants.dart';

class ProductInfo extends StatelessWidget {
  const ProductInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LIPSY LONDON'.toUpperCase(),
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(color: Colors.grey),
            ),

            const SizedBox(height: defaultPadding),
            Text(
              'Sleeveless Ruffle',
              style: Theme.of(context).textTheme.titleLarge!,
            ),

            const SizedBox(height: defaultPadding),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding / 2,
                    vertical: defaultPadding / 2,
                  ),
                  decoration: BoxDecoration(
                    color: successColor,
                    borderRadius: BorderRadius.circular(
                      defaultBorderRadious / 2,
                    ),
                  ),
                  child: Text(
                    'Available in stock',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/Star_filled.svg',
                      package: 'shop',
                    ),
                    const SizedBox(width: defaultPadding / 4),
                    Text('4.4', style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      ' (126 Reviews)',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium!.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: defaultPadding),
            Text(
              'Product info',
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: defaultPadding / 2),
            Text(
              "A cool gray cap in soft corduroy. Watch me. By buying cotton products from Lindex, you're supporting more responsibly...",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: defaultPadding / 2),
          ],
        ),
      ),
    );
  }
}
