import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// Apple 登录 UseCase 接口
abstract interface class LoginWithAppleUseCaseType {
  Future<AuthEntity> execute({
    required String identityToken,
    required String authorizationCode,
  });
}

/// Apple 登录 UseCase 实现
/// 对应 API：POST /api/auth/apple
class LoginWithAppleUseCase implements LoginWithAppleUseCaseType {
  final UserRepository _repository;

  const LoginWithAppleUseCase(this._repository);

  @override
  Future<AuthEntity> execute({
    required String identityToken,
    required String authorizationCode,
  }) async {
    if (identityToken.trim().isEmpty) {
      throw ArgumentError('identityToken 不能为空');
    }
    if (authorizationCode.trim().isEmpty) {
      throw ArgumentError('authorizationCode 不能为空');
    }

    return await _repository.loginWithApple(
      identityToken: identityToken,
      authorizationCode: authorizationCode,
    );
  }
}
