import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// Google 登录 UseCase 接口
abstract interface class LoginWithGoogleUseCaseType {
  Future<AuthEntity> execute({
    required String idToken,
  });
}

/// Google 登录 UseCase 实现
/// 对应 API：POST /api/auth/google
/// 首次登录自动注册，已有账号则更新 last_login_at
class LoginWithGoogleUseCase implements LoginWithGoogleUseCaseType {
  final UserRepository _repository;

  const LoginWithGoogleUseCase(this._repository);

  @override
  Future<AuthEntity> execute({
    required String idToken,
  }) async {
    if (idToken.trim().isEmpty) {
      throw ArgumentError('idToken 不能为空');
    }

    return await _repository.loginWithGoogle(idToken: idToken);
  }
}
