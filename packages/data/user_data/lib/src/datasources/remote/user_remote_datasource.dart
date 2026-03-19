import 'package:lt_network/network.dart';
import '../../models/models.dart';

abstract interface class UserRemoteDataSource {
  Future<UserModel> getCurrentUser();
  Future<void> logout();
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
}
