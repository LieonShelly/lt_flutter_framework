import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop/src/constants/constants.dart';

class NotifyMeCard extends StatelessWidget {
  const NotifyMeCard({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(
                context,
              ).textTheme.bodyLarge!.color!.withOpacity(0.1),
            ),
            borderRadius: BorderRadiusGeometry.circular(defaultBorderRadious),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
            child: Row(
              children: [
                SizedBox(
                  height: 40,
                  width: 40,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: EdgeInsets.zero,
                      side: const BorderSide(color: Colors.white10),
                    ),
                    child: SvgPicture.asset(
                      "assets/icons/Notification.svg",
                      package: 'shop',
                      colorFilter: ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: defaultPadding),
                Expanded(
                  child: Text(
                    "Notify when product back to stock.",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                CupertinoSwitch(
                  value: true,
                  onChanged: (_) {},
                  activeTrackColor: primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
