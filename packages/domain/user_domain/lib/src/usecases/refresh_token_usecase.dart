import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// 刷新 Token UseCase 接口
abstract interface class RefreshTokenUseCaseType {
  Future<AuthEntity> execute({
    required String refreshToken,
  });
}

/// 刷新 Token UseCase 实现
/// 对应 API：POST /api/auth/refresh
/// 使用 refresh token 换取新的 access token，响应同时返回新的 refresh token 和用户信息
class RefreshTokenUseCase implements RefreshTokenUseCaseType {
  final UserRepository _repository;

  const RefreshTokenUseCase(this._repository);

  @override
  Future<AuthEntity> execute({
    required String refreshToken,
  }) async {
    if (refreshToken.trim().isEmpty) {
      throw ArgumentError('refreshToken 不能为空');
    }

    return await _repository.refreshToken(refreshToken: refreshToken);
  }
}
