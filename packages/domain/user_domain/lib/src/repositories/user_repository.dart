import '../entities/entities.dart';

/// 用户相关的数据仓储接口
abstract interface class UserRepository {
  /// 获取当前用户信息
  Future<UserEntity> getCurrentUser();

  /// 登出
  Future<void> logout();
}
