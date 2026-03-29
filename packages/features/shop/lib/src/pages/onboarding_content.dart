import 'package:flutter/material.dart';
import 'package:shop/src/constants/constants.dart';

class OnboardingContent extends StatelessWidget {
  final bool isTextOnTop;
  final String title, description, image;

  const OnboardingContent({
    super.key,
    required this.isTextOnTop,
    required this.title,
    required this.description,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        if (isTextOnTop) titleDescription(context, title, description),
        if (isTextOnTop) const Spacer(),

        Image.asset(package: 'shop', image, fit: BoxFit.contain, height: 250),

        if (!isTextOnTop) const Spacer(),
        if (!isTextOnTop)
          titleDescription(
            context,
            'Find the item you’ve \nbeen looking for',
            'Here you’ll see rich varieties of goods, carefully classified for seamless browsing experience.',
          ),

        const Spacer(),
      ],
    );
  }

  Widget titleDescription(
    BuildContext context,
    String title,
    String description,
  ) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: defaultPadding),
        Text(description, textAlign: TextAlign.center),
      ],
    );
  }
}
