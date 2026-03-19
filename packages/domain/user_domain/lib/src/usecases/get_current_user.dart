import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// 获取当前用户的用例接口
abstract interface class GetCurrentUser {
  Future<UserEntity> call();
}

/// 获取当前用户的用例实现
class GetCurrentUserImpl implements GetCurrentUser {
  final UserRepository _repository;

  const GetCurrentUserImpl(this._repository);

  @override
  Future<UserEntity> call() async {
    return await _repository.getCurrentUser();
  }
}
