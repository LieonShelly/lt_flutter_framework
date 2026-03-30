// For preview
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop/shop.dart';
import 'package:shop/src/constants/constants.dart';

class CategoryModel {
  final String name;
  final String? svgSrc, route;

  CategoryModel({required this.name, this.svgSrc, this.route});
}

List<CategoryModel> demoCategories = [
  CategoryModel(name: "All Categories"),
  CategoryModel(
    name: "On Sale",
    svgSrc: "assets/icons/Sale.svg",
    route: onSaleScreenRoute,
  ),
  CategoryModel(name: "Man's", svgSrc: "assets/icons/Man.svg"),
  CategoryModel(name: "Woman’s", svgSrc: "assets/icons/Woman.svg"),
  CategoryModel(
    name: "Kids",
    svgSrc: "assets/icons/Child.svg",
    route: kidsScreenRoute,
  ),
];

class Categories extends StatelessWidget {
  const Categories({super.key});

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
            "Categories",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),

        const SizedBox(height: defaultPadding),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.only(left: defaultPadding),
            child: Row(
              spacing: defaultPadding / 2,
              children: [
                ...List.generate(
                  demoCategories.length,
                  (index) => CategoryBtn(
                    category: demoCategories[index].name,
                    svgSrc: demoCategories[index].svgSrc,
                    isActive: index == 0,
                    press: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CategoryBtn extends StatelessWidget {
  final String category;
  final String? svgSrc;
  final bool isActive;
  final VoidCallback press;

  const CategoryBtn({
    super.key,
    required this.category,
    this.svgSrc,
    required this.isActive,
    required this.press,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      borderRadius: const BorderRadius.all(Radius.circular(30)),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        decoration: BoxDecoration(
          color: isActive ? Theme.of(context).primaryColor : Colors.transparent,
          border: Border.all(
            color: isActive
                ? Colors.transparent
                : Theme.of(context).dividerColor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(30)),
        ),
        child: Row(
          children: [
            if (svgSrc != null)
              SvgPicture.asset(
                svgSrc!,
                package: 'shop',
                height: 20,
                colorFilter: ColorFilter.mode(
                  isActive ? Colors.white : Theme.of(context).iconTheme.color!,
                  BlendMode.srcIn,
                ),
              ),
            Text(
              category,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyLarge!.color!,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
