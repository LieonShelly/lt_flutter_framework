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

  @override
  Future<AuthEntity> loginWithApple({
    required String identityToken,
    required String authorizationCode,
  }) async {
    final model = await _remoteDataSource.loginWithApple(
      identityToken: identityToken,
      authorizationCode: authorizationCode,
    );
    return model.toEntity();
  }

  @override
  Future<AuthEntity> loginWithGoogle({
    required String idToken,
  }) async {
    final model = await _remoteDataSource.loginWithGoogle(idToken: idToken);
    return model.toEntity();
  }

  @override
  Future<AuthEntity> refreshToken({
    required String refreshToken,
  }) async {
    final model = await _remoteDataSource.refreshToken(
      refreshToken: refreshToken,
    );
    return model.toEntity();
  }
}
