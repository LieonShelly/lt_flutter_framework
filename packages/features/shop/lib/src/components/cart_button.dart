import 'package:flutter/material.dart';
import 'package:shop/src/constants/constants.dart';

class CartButton extends StatelessWidget {
  final double price;
  final String title, subTitle;
  final VoidCallback press;

  const CartButton({
    super.key,
    required this.price,
    this.title = "Buy Now",
    this.subTitle = "Unit price",
    required this.press,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        child: SizedBox(
          height: 64,
          child: Material(
            color: primaryMaterialColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(defaultBorderRadious),
            ),
            child: InkWell(
              onTap: press,
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: defaultPadding,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${price.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleSmall!
                                .copyWith(color: Colors.white),
                          ),

                          Text(
                            subTitle,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    flex: 3,
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.black.withValues(alpha: 0.15),
                      child: Text(
                        title,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium!.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
