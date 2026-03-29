import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/shop.dart';
import 'package:shop/src/constants/constants.dart';
import 'package:shop/src/pages/onboarding_content.dart';
import 'package:lt_uicomponent/uicomponent.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<StatefulWidget> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _pageIndex = 0;
  final List<Onboard> _onboardData = [
    Onboard(
      image: "assets/Illustration/Illustration-0.png",
      imageDarkTheme: "assets/Illustration/Illustration_darkTheme_0.png",
      title: "Find the item you’ve \nbeen looking for",
      description:
          "Here you’ll see rich varieties of goods, carefully classified for seamless browsing experience.",
    ),
    Onboard(
      image: "assets/Illustration/Illustration-1.png",
      imageDarkTheme: "assets/Illustration/Illustration_darkTheme_1.png",
      title: "Get those shopping \nbags filled",
      description:
          "Add any item you want to your cart, or save it on your wishlist, so you don’t miss it in your future purchases.",
    ),
    Onboard(
      image: "assets/Illustration/Illustration-2.png",
      imageDarkTheme: "assets/Illustration/Illustration_darkTheme_2.png",
      title: "Fast & secure \npayment",
      description: "There are many payment options available for your ease.",
    ),
    Onboard(
      image: "assets/Illustration/Illustration-3.png",
      imageDarkTheme: "assets/Illustration/Illustration_darkTheme_3.png",
      title: "Package tracking",
      description:
          "In particular, Shoplon can pack your orders, and help you seamlessly manage your shipments.",
    ),
    Onboard(
      image: "assets/Illustration/Illustration-4.png",
      imageDarkTheme: "assets/Illustration/Illustration_darkTheme_4.png",
      title: "Nearby stores",
      description:
          "Easily track nearby shops, browse through their items and get information about their prodcuts.",
    ),
  ];

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, logInScreenRoute);
                  },
                  child: Text(
                    "Skip",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  itemCount: _onboardData.length,
                  onPageChanged: (value) {
                    setState(() {
                      _pageIndex = value;
                    });
                  },
                  itemBuilder: (context, index) => OnboardingContent(
                    isTextOnTop: index.isOdd,
                    title: _onboardData[index].title,
                    description: _onboardData[index].description,
                    image:
                        (Theme.of(context).brightness == Brightness.dark &&
                            _onboardData[index].imageDarkTheme != null)
                        ? _onboardData[index].imageDarkTheme!
                        : _onboardData[index].image,
                  ),
                ),
              ),
              Row(
                children: [
                  ...List.generate(
                    _onboardData.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: defaultPadding / 4),
                      child: DotIndicator(
                        isActive: index == _pageIndex,
                        activeColor: Color(0xFF7B61FF),
                      ),
                    ),
                  ),

                  const Spacer(),
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_pageIndex < _onboardData.length - 1) {
                          _pageController.nextPage(
                            duration: defaultDuration,
                            curve: Curves.ease,
                          );
                        } else {
                          Navigator.pushNamed(context, logInScreenRoute);
                        }
                      },
                      style: ElevatedButton.styleFrom(shape: CircleBorder()),
                      child: SvgPicture.asset(
                        "assets/icons/Arrow - Right.svg",
                        package: 'shop',
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class Onboard {
  final String image, title, description;
  final String? imageDarkTheme;

  const Onboard({
    required this.image,
    required this.title,
    required this.description,
    this.imageDarkTheme,
  });
}
