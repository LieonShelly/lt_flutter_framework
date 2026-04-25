import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:user_domain/user_domain.dart';

import 'providers/user_providers.dart';

part 'login_view_model.g.dart';

enum LoginType { apple, google }

sealed class LoginState {
  const LoginState();
}

class LoginIdle extends LoginState {
  const LoginIdle();
}

class LoginLoading extends LoginState {
  final LoginType type;
  const LoginLoading(this.type);
}

class LoginSuccess extends LoginState {
  final AuthEntity auth;
  const LoginSuccess(this.auth);
}

class LoginFailure extends LoginState {
  final String message;
  const LoginFailure(this.message);
}

@riverpod
class LoginViewModel extends _$LoginViewModel {
  late final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    clientId:
        "92621954916-ujfsjlbj9ubbs26ifcv0dq0af8jltck4.apps.googleusercontent.com",
  );

  @override
  LoginState build() => const LoginIdle();

  Future<void> signInWithApple() async {
    if (state is LoginLoading) return;
    state = const LoginLoading(LoginType.apple);

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final identityToken = credential.identityToken;
      final authorizationCode = credential.authorizationCode;

      if (identityToken == null) {
        state = const LoginFailure('Apple 授权失败：identityToken 为空');
        return;
      }
      final useCase = ref.read(loginWithAppleProvider);
      final auth = await useCase.execute(
        identityToken: identityToken,
        authorizationCode: authorizationCode,
      );

      state = LoginSuccess(auth);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        state = const LoginIdle();
      } else {
        state = LoginFailure('Apple 登录失败1：${e.message}');
      }
    } catch (e) {
      state = LoginFailure('Apple 登录失败2：$e');
    }
  }

  Future<void> signInWithGoogle() async {
    if (state is LoginLoading) return;
    state = const LoginLoading(LoginType.google);

    try {
      final account = await _googleSignIn.signIn();

      if (account == null) {
        state = const LoginIdle();
        return;
      }

      // 2. 获取 Auth 信息拿到 idToken
      final googleAuth = await account.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        state = const LoginFailure('Google 授权失败：idToken 为空');
        return;
      }

      final useCase = ref.read(loginWithGoogleProvider);
      final auth = await useCase.execute(idToken: idToken);

      state = LoginSuccess(auth);
    } catch (e) {
      state = LoginFailure('Google 登录失败：$e');
    }
  }
}
