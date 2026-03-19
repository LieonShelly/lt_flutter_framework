import '../entities/entities.dart';

abstract interface class UserRepository {

  Future<UserEntity> getCurrentUser();

  Future<void> logout();
}
