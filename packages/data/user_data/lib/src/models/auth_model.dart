import 'package:lt_annotation/annotation.dart';
import 'package:user_domain/user_domain.dart';
import 'user_model.dart';

part 'auth_model.lt_model.dart';

/// 登录认证响应 DTO
/// 对应 API 响应中的 data 字段：{ access_token, refresh_token, user }
@ltDeserialization
class AuthModel {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  AuthModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) =>
      _$AuthModelFromJson(json);

  AuthEntity toEntity() {
    return AuthEntity(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user.toEntity(),
    );
  }
}
