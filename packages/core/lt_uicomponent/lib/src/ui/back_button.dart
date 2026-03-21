import 'blur_filter.dart';
import 'package:flutter/material.dart';
import 'package:lt_uicomponent/src/theme/theme.dart';

class CustomBackButton extends StatelessWidget {
  final bool blur;
  final GestureTapCallback? onTap;

  const CustomBackButton({super.key, this.onTap, this.blur = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 40,
      child: Stack(
        children: [
          if (blur) ClipRect(child: BackdropFilter(filter: kBlurFilter)),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(8.0),
              onTap: () {
                if (onTap != null) {
                  onTap!();
                }
              },
              child: Center(
                child: Icon(
                  size: 24.0,
                  Icons.arrow_back,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
