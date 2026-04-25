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

  // ─── 用户设置 ───────────────────────────────────────────────────────────────
  Future<void> saveDeviceToken(String deviceToken);
  Future<void> saveTimezone(String timestamp);
  Future<void> updateQodStrategy(String strategy);
  Future<List<QodStrategyOptionModel>> fetchQodStrategyOptions();
  Future<MeModel> fetchMe();
  Future<void> updateNickname(String? nickname);
  Future<ReminderSlotModel> fetchReminderSlot();
  Future<ReminderSlotModel> setReminderSlot(String? slot);
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

  // ─── 用户设置 ───────────────────────────────────────────────────────────────

  @override
  Future<void> saveDeviceToken(String deviceToken) async {
    await _apiClient.post('/api/device-token', data: {
      'deviceToken': deviceToken,
    });
  }

  @override
  Future<void> saveTimezone(String timestamp) async {
    await _apiClient.post('/api/timezone', data: {
      'timestamp': timestamp,
    });
  }

  @override
  Future<void> updateQodStrategy(String strategy) async {
    await _apiClient.post('/api/qod-strategy', data: {
      'qod_strategy': strategy,
    });
  }

  @override
  Future<List<QodStrategyOptionModel>> fetchQodStrategyOptions() async {
    final response = await _apiClient.get('/api/qod-strategy-options');
    final list = response as List<dynamic>;
    return list
        .map((e) => QodStrategyOptionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MeModel> fetchMe() async {
    final response = await _apiClient.get('/api/me');
    return MeModel.fromJson(response['data']);
  }

  @override
  Future<void> updateNickname(String? nickname) async {
    await _apiClient.post('/api/me', data: {
      'nickname': nickname,
    });
  }

  @override
  Future<ReminderSlotModel> fetchReminderSlot() async {
    final response = await _apiClient.get('/api/me/reminder');
    return ReminderSlotModel.fromJson(response['data']);
  }

  @override
  Future<ReminderSlotModel> setReminderSlot(String? slot) async {
    final response = await _apiClient.post('/api/me/reminder', data: {
      'slot': slot,
    });
    return ReminderSlotModel.fromJson(response['data']);
  }
}

