import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop/src/components/cart_button.dart';
import 'package:shop/src/components/custom_modal_bottom_sheet.dart';
import 'package:shop/src/components/notify_me_card.dart';
import 'package:shop/src/components/product_card.dart';
import 'package:shop/src/components/product_list_title.dart';
import 'package:shop/src/constants/constants.dart';
import 'package:shop/src/pages/product/product_buy_now_screen.dart';
import 'package:shop/src/pages/product/product_images.dart';
import 'package:shop/src/pages/product/product_info.dart';
import 'package:shop/src/pages/product/review_card.dart';

class ProductDetailSceen extends StatelessWidget {
  final bool isProductAvailable;

  const ProductDetailSceen({super.key, this.isProductAvailable = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: isProductAvailable
          ? CartButton(
              price: 140,
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: const ProductBuyNowScreen(),
                );
              },
            )
          : NotifyMeCard(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              floating: true,
              actions: [
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
            ProductImages(
              images: [productDemoImg1, productDemoImg2, productDemoImg3],
            ),
            const ProductInfo(),
            ProductListTitle(
              svgSrc: 'assets/icons/Product.svg',
              title: 'Product Details',
              isShowBottomBorader: false,
              press: () {},
            ),
            ProductListTitle(
              svgSrc: "assets/icons/Delivery.svg",
              title: "Shipping Information",
              isShowBottomBorader: false,
              press: () {},
            ),
            ProductListTitle(
              svgSrc: "assets/icons/Return.svg",
              title: "Returns",
              isShowBottomBorader: true,
              press: () {},
            ),
            ReviewCard(),
            ProductListTitle(
              svgSrc: "assets/icons/Chat.svg",
              title: "Reviews",
              isShowBottomBorader: true,
              press: () {},
            ),

            SliverPadding(
              padding: const EdgeInsets.all(defaultPadding),
              sliver: SliverToBoxAdapter(
                child: Text(
                  "You may also like",
                  style: Theme.of(context).textTheme.titleSmall!,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsetsGeometry.only(
                      left: defaultPadding,
                      right: index == 4 ? defaultPadding : 0,
                    ),
                    child: ProductCard(
                      image: productDemoImg2,
                      brandName: 'LIPSY LONDON',
                      title: 'Sleeveless Tiered Dobby Swing Dress',
                      price: 22,
                      press: () {},
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: defaultPadding)),
          ],
        ),
      ),
    );
  }
}
