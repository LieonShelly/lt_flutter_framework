import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/shop.dart';
import 'package:shop/src/constants/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<StatefulWidget> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  final List _pages = const [HomeScreen()];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(),
      body: PageTransitionSwitcher(
        duration: defaultDuration,
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
          return FadeThroughTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: bottomBar(),
    );
  }

  PreferredSizeWidget appbar() {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      leading: const SizedBox(),
      leadingWidth: 0,
      centerTitle: false,
      title: SvgPicture.asset(
        "assets/logo/Shoplon.svg",
        package: 'shop',
        colorFilter: ColorFilter.mode(
          Theme.of(context).iconTheme.color!,
          BlendMode.srcIn,
        ),
        height: 20,
        width: 100,
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, searchScreenRoute);
          },
          icon: SvgPicture.asset(
            "assets/icons/Search.svg",
            package: 'shop',
            height: 24,
            colorFilter: ColorFilter.mode(
              Theme.of(context).textTheme.bodyLarge!.color!,
              BlendMode.srcIn,
            ),
          ),
        ),

        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, notificationsScreenRoute);
          },
          icon: SvgPicture.asset(
            "assets/icons/Notification.svg",
            package: 'shop',
            height: 24,
            colorFilter: ColorFilter.mode(
              Theme.of(context).textTheme.bodyLarge!.color!,
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomBar() {
    SvgPicture svgIcon(String src, {Color? color}) {
      return SvgPicture.asset(
        src,
        package: 'shop',
        height: 24,
        colorFilter: ColorFilter.mode(
          color ??
              Theme.of(context).iconTheme.color!.withOpacity(
                Theme.of(context).brightness == Brightness.dark ? 0.3 : 1,
              ),
          BlendMode.srcIn,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.only(top: defaultPadding / 2),
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : const Color(0xFF101015),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (value) {
          if (value != _currentIndex) {
            setState(() {
              _currentIndex = value;
            });
          }
        },
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF101015),
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 12,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.transparent,
        items: [
          BottomNavigationBarItem(
            icon: svgIcon("assets/icons/Shop.svg"),
            activeIcon: svgIcon("assets/icons/Shop.svg", color: primaryColor),
            label: "Shop",
          ),
          BottomNavigationBarItem(
            icon: svgIcon("assets/icons/Category.svg"),
            activeIcon: svgIcon(
              "assets/icons/Category.svg",
              color: primaryColor,
            ),
            label: "Discover",
          ),
          BottomNavigationBarItem(
            icon: svgIcon("assets/icons/Bookmark.svg"),
            activeIcon: svgIcon(
              "assets/icons/Bookmark.svg",
              color: primaryColor,
            ),
            label: "Bookmark",
          ),
          BottomNavigationBarItem(
            icon: svgIcon("assets/icons/Bag.svg"),
            activeIcon: svgIcon("assets/icons/Bag.svg", color: primaryColor),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: svgIcon("assets/icons/Profile.svg"),
            activeIcon: svgIcon(
              "assets/icons/Profile.svg",
              color: primaryColor,
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
