import '../entities/entities.dart';
import '../repositories/repositories.dart';

abstract interface class GetCurrentUser {
  Future<UserEntity> call();
}

class GetCurrentUserImpl implements GetCurrentUser {
  final UserRepository _repository;

  const GetCurrentUserImpl(this._repository);

  @override
  Future<UserEntity> call() async {
    return await _repository.getCurrentUser();
  }
}
