import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/src/constants/constants.dart';

class ProductListTitle extends StatelessWidget {
  final String svgSrc, title;
  final bool isShowBottomBorader;
  final VoidCallback press;

  const ProductListTitle({
    super.key,
    required this.svgSrc,
    required this.title,
    required this.isShowBottomBorader,
    required this.press,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            const Divider(height: 1),
            ListTile(
              onTap: press,
              minLeadingWidth: 24,
              leading: SvgPicture.asset(
                svgSrc,
                height: 24,
                package: 'shop',
                colorFilter: ColorFilter.mode(
                  Theme.of(context).textTheme.bodyLarge!.color!,
                  BlendMode.srcIn,
                ),
              ),
              title: Text(title),
              trailing: SvgPicture.asset(
                "assets/icons/miniRight.svg",
                package: 'shop',
                color: Theme.of(context).textTheme.bodyMedium!.color,
              ),
            ),
            if (isShowBottomBorader) const Divider(height: 1),
          ],
        ),
      ),
    );
  }
}
