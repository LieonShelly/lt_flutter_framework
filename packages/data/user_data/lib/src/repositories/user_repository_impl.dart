import 'package:lt_network/network.dart';
import 'package:user_domain/user_domain.dart';
import '../datasources/datasources.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  const UserRepositoryImpl(this._remoteDataSource, this._tokenStorage);

  @override
  Future<UserEntity> getCurrentUser() async {
    final model = await _remoteDataSource.getCurrentUser();
    return model.toEntity();
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.clear();
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
    await _tokenStorage.saveTokens(model.accessToken, model.refreshToken);
    return model.toEntity();
  }

  @override
  Future<AuthEntity> loginWithGoogle({required String idToken}) async {
    final model = await _remoteDataSource.loginWithGoogle(idToken: idToken);
    await _tokenStorage.saveTokens(model.accessToken, model.refreshToken);
    return model.toEntity();
  }

  @override
  Future<AuthEntity> refreshToken({required String refreshToken}) async {
    final model = await _remoteDataSource.refreshToken(
      refreshToken: refreshToken,
    );
    await _tokenStorage.saveTokens(model.accessToken, model.refreshToken);
    return model.toEntity();
  }

  // ─── 用户设置 ───────────────────────────────────────────────────────────────

  @override
  Future<void> saveDeviceToken(String deviceToken) async {
    await _remoteDataSource.saveDeviceToken(deviceToken);
  }

  @override
  Future<void> saveTimezone(String timestamp) async {
    await _remoteDataSource.saveTimezone(timestamp);
  }

  @override
  Future<void> updateQodStrategy(QodStrategy strategy) async {
    await _remoteDataSource.updateQodStrategy(strategy.toApiString());
  }

  @override
  Future<List<QodStrategyOptionEntity>> fetchQodStrategyOptions() async {
    final models = await _remoteDataSource.fetchQodStrategyOptions();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<MeEntity> fetchMe() async {
    final model = await _remoteDataSource.fetchMe();
    return model.toEntity();
  }

  @override
  Future<void> updateNickname(String? nickname) async {
    await _remoteDataSource.updateNickname(nickname);
  }

  @override
  Future<ReminderSlotEntity> fetchReminderSlot() async {
    final model = await _remoteDataSource.fetchReminderSlot();
    return model.toEntity();
  }

  @override
  Future<ReminderSlotEntity> setReminderSlot(ReminderSlot? slot) async {
    final model = await _remoteDataSource.setReminderSlot(slot?.toApiString());
    return model.toEntity();
  }
}
