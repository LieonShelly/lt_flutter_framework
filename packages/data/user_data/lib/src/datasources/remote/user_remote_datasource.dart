import 'package:lt_network/network.dart';
import '../../models/models.dart';

/// 用户相关的远程数据源接口
abstract interface class UserRemoteDataSource {
  Future<UserModel> getCurrentUser();
  Future<void> logout();
}

/// 用户相关的远程数据源实现
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
