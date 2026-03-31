import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/src/constants/constants.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(defaultPadding),
      sliver: SliverToBoxAdapter(
        child: Container(
          // height: 200,
          padding: const EdgeInsets.symmetric(
            horizontal: defaultPadding,
            vertical: defaultPadding * 2,
          ),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).textTheme.bodyLarge!.color!.withOpacity(0.035),
            borderRadius: BorderRadius.all(
              Radius.circular(defaultBorderRadious),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: "4.3",
                        style: Theme.of(context).textTheme.headlineSmall!
                            .copyWith(fontWeight: FontWeight.w500),
                        children: [
                          TextSpan(
                            text: '/5',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: defaultPadding),
                    Text(
                      'Based on 128 Reviews',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: defaultPadding),
                    RatingBar.builder(
                      initialRating: 3.5,
                      itemSize: 20,
                      itemPadding: const EdgeInsets.only(
                        right: defaultPadding / 4,
                      ),
                      unratedColor: Theme.of(
                        context,
                      ).textTheme.bodyLarge!.color!.withOpacity(0.08),
                      glow: false,
                      allowHalfRating: true,
                      ignoreGestures: true,
                      onRatingUpdate: (value) {},
                      itemBuilder: (context, index) {
                        return SvgPicture.asset(
                          "assets/icons/Star_filled.svg",
                          package: 'shop',
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    RateBar(star: 4, value: 0.1),
                    RateBar(star: 5, value: 0.5),
                    RateBar(star: 3, value: 0.2),
                    RateBar(star: 2, value: 0.4),
                    RateBar(star: 1, value: 0.9),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RateBar extends StatelessWidget {
  const RateBar({super.key, required this.star, required this.value});
  final int star;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$star Star'),
        const SizedBox(width: defaultPadding),
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(defaultBorderRadious),
            ),
            child: LinearProgressIndicator(
              value: value,
              color: warningColor,
              backgroundColor: Theme.of(
                context,
              ).textTheme.bodyLarge!.color!.withOpacity(0.05),
            ),
          ),
        ),
      ],
    );
  }
}
