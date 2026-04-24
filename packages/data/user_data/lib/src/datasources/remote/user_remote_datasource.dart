import 'package:lt_network/network.dart';
import '../../models/models.dart';

abstract interface class UserRemoteDataSource {
  Future<UserModel> getCurrentUser();
  Future<void> logout();
  Future<AuthModel> loginWithApple({
    required String identityToken,
    required String authorizationCode,
  });
  Future<AuthModel> loginWithGoogle({
    required String idToken,
  });
  Future<AuthModel> refreshToken({
    required String refreshToken,
  });
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiClientType _apiClient;

  const UserRemoteDataSourceImpl(this._apiClient);

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get('/api/user/me');
    return UserModel.fromJson(response['data']);
  }

  @override
  Future<void> logout() async {
    await _apiClient.post('/api/auth/logout');
  }

  @override
  Future<AuthModel> loginWithApple({
    required String identityToken,
    required String authorizationCode,
  }) async {
    final response = await _apiClient.post('/api/auth/apple', data: {
      'identityToken': identityToken,
      'authorizationCode': authorizationCode,
    });
    return AuthModel.fromJson(response['data']);
  }

  @override
  Future<AuthModel> loginWithGoogle({
    required String idToken,
  }) async {
    final response = await _apiClient.post('/api/auth/google', data: {
      'idToken': idToken,
    });
    return AuthModel.fromJson(response['data']);
  }

  @override
  Future<AuthModel> refreshToken({
    required String refreshToken,
  }) async {
    final response = await _apiClient.post('/api/auth/refresh', data: {
      'refresh_token': refreshToken,
    });
    return AuthModel.fromJson(response['data']);
  }
}
