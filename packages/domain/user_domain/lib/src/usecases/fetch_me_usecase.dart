import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// 获取当前登录用户的个人信息 UseCase
/// API: GET /api/me
abstract interface class FetchMeUseCaseType {
  Future<MeEntity> execute();
}

class FetchMeUseCase implements FetchMeUseCaseType {
  final UserRepository _repository;

  const FetchMeUseCase(this._repository);

  @override
  Future<MeEntity> execute() async {
    return await _repository.fetchMe();
  }
}
