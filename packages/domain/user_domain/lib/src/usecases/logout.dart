import '../repositories/repositories.dart';

/// 登出的用例接口
abstract interface class Logout {
  Future<void> call();
}

/// 登出的用例实现
class LogoutImpl implements Logout {
  final UserRepository _repository;

  const LogoutImpl(this._repository);

  @override
  Future<void> call() async {
    return await _repository.logout();
  }
}
