import '../repositories/repositories.dart';

abstract interface class Logout {
  Future<void> call();
}

class LogoutImpl implements Logout {
  final UserRepository _repository;

  const LogoutImpl(this._repository);

  @override
  Future<void> call() async {
    return await _repository.logout();
  }
}
