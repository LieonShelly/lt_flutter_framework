import '../entities/entities.dart';

abstract interface class UserRepository {

  Future<UserEntity> getCurrentUser();

  Future<void> logout();

  /// Apple ID 登录
  Future<AuthEntity> loginWithApple({
    required String identityToken,
    required String authorizationCode,
  });

  /// Google ID Token 登录（首次登录自动注册）
  Future<AuthEntity> loginWithGoogle({
    required String idToken,
  });

  /// 使用 refresh token 获取新的 access token
  Future<AuthEntity> refreshToken({
    required String refreshToken,
  });

  // ─── 用户设置 ───────────────────────────────────────────────────────────────

  /// 保存设备 DeviceToken（用于推送通知）
  Future<void> saveDeviceToken(String deviceToken);

  /// 保存用户时区（ISO 8601 带 UTC 偏移的时间戳）
  Future<void> saveTimezone(String timestamp);

  /// 更新 QoD 策略（RANDOM / PINNED / MIXED）
  Future<void> updateQodStrategy(QodStrategy strategy);

  /// 获取可用的 QoD 策略选项列表
  Future<List<QodStrategyOptionEntity>> fetchQodStrategyOptions();

  /// 获取当前登录用户的个人信息
  Future<MeEntity> fetchMe();

  /// 更新当前登录用户昵称（传 null 表示清空）
  Future<void> updateNickname(String? nickname);

  /// 获取每日提醒时段（null 表示已关闭）
  Future<ReminderSlotEntity> fetchReminderSlot();

  /// 设置每日提醒时段（传 null 表示关闭提醒）
  Future<ReminderSlotEntity> setReminderSlot(ReminderSlot? slot);
}

