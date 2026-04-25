import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lt_uicomponent/uicomponent.dart';

import 'login_view_model.dart';

class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginViewModelProvider);
    final vm = ref.read(loginViewModelProvider.notifier);
    final isLoading = loginState is LoginLoading;

    // 登录成功后的跳转由路由层监听处理（可在 app_router 中通过 redirect 实现）
    ref.listen<LoginState>(loginViewModelProvider, (_, next) {
      if (next is LoginFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.oat,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── 品牌 Logo 区域 ─────────────────────────────────────────────────
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
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── 底部登录按钮区域 ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  // Apple 登录
                  _LoginButton(
                    onTap: isLoading ? null : vm.signInWithApple,
                    backgroundColor: AppColors.black,
                    borderColor: AppColors.black,
                    isLoading: isLoading,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SvgAsset(IconName.apple, width: 16, height: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Sign in with Apple',
                          style: AppTextStyle.sfProBold(
                            fontSize: 17,
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Google 登录
                  _LoginButton(
                    onTap: isLoading ? null : vm.signInWithGoogle,
                    backgroundColor: AppColors.oat,
                    borderColor: AppColors.greyDark,
                    isLoading: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgAsset(IconName.google, width: 22, height: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Sign in with Google',
                          style: AppTextStyle.sfProBold(
                            fontSize: 17,
                            color: AppColors.greyDark,
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

// ─── 通用登录按钮 ──────────────────────────────────────────────────────────────

class _LoginButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color borderColor;
  final bool isLoading;
  final Widget child;

  const _LoginButton({
    required this.onTap,
    required this.backgroundColor,
    required this.borderColor,
    required this.isLoading,
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
          child: SizedBox(
            height: 54,
            width: double.infinity,
            child: isLoading
                ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    ),
                  )
                : child,
          ),
        ),
      ),
    );
  }
}
