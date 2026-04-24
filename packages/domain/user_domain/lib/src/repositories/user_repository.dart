import '../entities/entities.dart';

abstract interface class UserRepository {

  Future<UserEntity> getCurrentUser();

  Future<void> logout();

  /// Apple ID 登录
  Future<AuthEntity> loginWithApple({
    required String identityToken,
    required String authorizationCode,
  });

  /// Google ID Token 登录（首次登录自动注册）
  Future<AuthEntity> loginWithGoogle({
    required String idToken,
  });

  /// 使用 refresh token 获取新的 access token
  Future<AuthEntity> refreshToken({
    required String refreshToken,
  });
}
