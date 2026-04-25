import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lt_uicomponent/uicomponent.dart';

class LoginView extends ConsumerWidget {
  final VoidCallback onAppleSignIn;
  final VoidCallback onGoogleSignIn;

  const LoginView({
    super.key,
    required this.onAppleSignIn,
    required this.onGoogleSignIn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgAsset(IconName.sun, width: 45, height: 45),
                    const SizedBox(height: 84),
                    Text(
                      'the little things',
                      style: AppTextStyle.feltTipSeniorRegular(
                        fontSize: 36,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  _LoginButton(
                    onTap: onAppleSignIn,
                    backgroundColor: Colors.black,
                    borderColor: Colors.black,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SvgAsset(IconName.apple, width: 16, height: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Sign in with Apple',
                          style: AppTextStyle.poppins(
                            fontSize: 17,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  _LoginButton(
                    onTap: onGoogleSignIn,
                    backgroundColor: const Color(0xFFFFFDF8),
                    borderColor: const Color(0xFF1D1D1D),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgAsset(IconName.google, width: 22, height: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Sign in with Google',
                          style: AppTextStyle.poppins(
                            fontSize: 17,
                            color: const Color(0xFF323232),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color borderColor;
  final Widget child;

  const _LoginButton({
    required this.onTap,
    required this.backgroundColor,
    required this.borderColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: SizedBox(height: 54, width: double.infinity, child: child),
        ),
      ),
    );
  }
}
