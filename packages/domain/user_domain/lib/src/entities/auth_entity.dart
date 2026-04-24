import 'user_entity.dart';

/// 登录认证结果实体（纯业务对象）
class AuthEntity {
  final String accessToken;
  final String refreshToken;
  final UserEntity user;

  const AuthEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });
}
