import 'package:flutter/material.dart';
import 'package:shop/src/components/network_image_with_loader.dart';
import 'package:shop/src/constants/constants.dart';

class ProductImages extends StatefulWidget {
  final List<String> images;

  const ProductImages({super.key, required this.images});

  @override
  State<StatefulWidget> createState() => _ProductImagesState();
}

class _ProductImagesState extends State<ProductImages> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: 0.9,
    );
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (value) {
                setState(() {
                  _currentPage = value;
                });
              },
              itemBuilder: (context, index) {
                final image = widget.images[index];
                return Padding(
                  padding: EdgeInsets.only(right: defaultPadding),
                  child: NetworkImageWithLoader(
                    url: image,
                    radius: defaultBorderRadious,
                  ),
                );
              },
            ),

            Positioned(
              height: 20,
              bottom: 24,
              right: MediaQuery.of(context).size.width * 0.15,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: defaultPadding * 0.75,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.all(
                    Radius.circular(defaultBorderRadious),
                  ),
                ),
                child: Row(
                  children: [
                    ...List.generate(
                      widget.images.length,
                      (index) => Padding(
                        padding: EdgeInsets.only(
                          right: index == (widget.images.length - 1)
                              ? 0
                              : defaultPadding / 4,
                        ),
                        child: CircleAvatar(
                          radius: 3,
                          backgroundColor: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .color!
                              .withOpacity(index == _currentPage ? 1 : 0.2),
                        ),
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
  }
}
