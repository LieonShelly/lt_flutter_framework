import 'package:user_domain/user_domain.dart';
import '../datasources/datasources.dart';
import '../models/models.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;

  const UserRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserEntity> getCurrentUser() async {
    final model = await _remoteDataSource.getCurrentUser();
    return model.toEntity();
  }

  @override
  Future<void> logout() async {
    await _remoteDataSource.logout();
  }
}
