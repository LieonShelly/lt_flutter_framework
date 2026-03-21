import 'package:booking/booking.dart';
import 'package:booking/src/home/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lt_uicomponent/uicomponent.dart';

class HomeHeader extends StatelessWidget {
  final HomeViewmodel viewmodel;

  const HomeHeader({super.key, required this.viewmodel});

  @override
  Widget build(BuildContext context) {
    final user = viewmodel.user;
    if (user == null) {
      return const SizedBox();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipOval(
              child: Image.asset(
                user.picture,
                width: Dimens.of(context).profilePictureSize,
                height: Dimens.of(context).profilePictureSize,
              ),
            ),
          ],
        ),
        const SizedBox(height: Dimens.paddingVertical),
        _Title(text: Applocalization.of(context).nameTrips(user.name)),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  final String text;
  const _Title({required this.text});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => RadialGradient(
        center: Alignment.bottomLeft,
        radius: 2,
        colors: [Colors.purple.shade700, Colors.purple.shade400],
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(
        text,
        style: GoogleFonts.rubik(
          textStyle: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
    );
  }
}
