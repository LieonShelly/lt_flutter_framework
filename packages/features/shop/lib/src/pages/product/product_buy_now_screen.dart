import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/src/components/cart_button.dart';
import 'package:shop/src/components/network_image_with_loader.dart';
import 'package:shop/src/components/product_list_title.dart';
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
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding,
                  ),
                  sliver: SliverToBoxAdapter(
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
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                    children: [
                                      TextSpan(
                                        text: " \$${222.toStringAsFixed(2)}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .copyWith(
                                              color: Colors.grey,
                                              decoration:
                                                  TextDecoration.lineThrough,
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
                                          color: Theme.of(
                                            context,
                                          ).iconTheme.color,
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
                                              .copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
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
                                          color: Theme.of(
                                            context,
                                          ).iconTheme.color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: defaultPadding * 2),
                        const Divider(height: 1),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(left: 0, right: 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: defaultPadding,
                      children: [
                        const SizedBox(height: defaultPadding),
                        Padding(
                          padding: const EdgeInsets.only(left: defaultPadding),
                          child: Text(
                            'Select Color',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),

                        SelectedColor(
                          colors: [
                            Color(0xFFEA6262),
                            Color(0xFFB1CC63),
                            Color(0xFFFFBF5F),
                            Color(0xFF9FE1DD),
                            Color(0xFFC482DB),
                          ],
                          selectedColorIndex: 2,
                          press: (value) {},
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding,
                    vertical: defaultPadding,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: defaultPadding,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 0),
                          child: Text(
                            'Select Size',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),

                        SelectedSize(
                          sizes: ["S", "M", "L", "XL", "XL"],
                          selectedIndex: 2,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                  sliver: ProductListTitle(
                    svgSrc: 'assets/icons/Sizeguid.svg',
                    title: "Size guide",
                    isShowBottomBorader: true,
                    press: () {},
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      spacing: defaultPadding,
                      children: [
                        Text(
                          'Store pickup availability',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          'Select a size to check store availability and In-Store pickup options.',
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: defaultPadding,
                  ),
                  sliver: ProductListTitle(
                    title: "Check stores",
                    svgSrc: "assets/icons/Stores.svg",
                    isShowBottomBorader: true,
                    press: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ColorDot extends StatelessWidget {
  final Color color;
  final bool isActive;

  const ColorDot({super.key, required this.color, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: defaultDuration,
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: isActive ? primaryColor : Colors.transparent),
      ),
      padding: EdgeInsets.all(isActive ? defaultPadding / 4 : 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(backgroundColor: color),
          AnimatedOpacity(
            opacity: isActive ? 1 : 0,
            duration: defaultDuration,
            child: CircleAvatar(
              radius: 8,
              backgroundColor: primaryColor,
              child: SvgPicture.asset(
                "assets/icons/Singlecheck.svg",
                package: 'shop',
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SelectedColor extends StatelessWidget {
  final List<Color> colors;
  final int selectedColorIndex;
  final ValueChanged<int> press;

  const SelectedColor({
    super.key,
    required this.colors,
    required this.selectedColorIndex,
    required this.press,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          colors.length,
          (index) => Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? defaultPadding : defaultPadding / 2,
            ),
            child: ColorDot(
              color: colors[index],
              isActive: selectedColorIndex == index,
            ),
          ),
        ),
      ),
    );
  }
}

class SelectedSize extends StatelessWidget {
  final List<String> sizes;
  final int selectedIndex;

  const SelectedSize({
    super.key,
    required this.sizes,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Row(
        spacing: defaultPadding,
        children: List.generate(sizes.length, (index) {
          return SizedBox(
            width: 40,
            height: 40,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(0),
                shape: CircleBorder(),
                side: selectedIndex == index
                    ? const BorderSide(color: primaryColor)
                    : null,
              ),
              onPressed: () {},
              child: Text(
                sizes[index].toUpperCase(),
                style: TextStyle(
                  color: selectedIndex == index
                      ? purpleColor
                      : Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
