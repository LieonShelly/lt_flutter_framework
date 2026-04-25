import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network_core/token_storage.dart';

class SecureTokenStorage implements TokenStorage {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions.defaultOptions,
  );

  static const _kAccessTokenKey = 'access_token';
  static const _kRefreshTokenKey = 'refresh_token';

  String? _cachedAccessToken;
  String? _cachedRefreshToken;

  @override
  Future<String?> getAccessToken() async {
    if (_cachedAccessToken != null) return _cachedAccessToken;
    _cachedAccessToken = await _storage.read(key: _kAccessTokenKey);
    return _cachedAccessToken;
  }

  @override
  Future<String?> getRefreshToken() async {
    if (_cachedRefreshToken != null) return _cachedRefreshToken;
    _cachedRefreshToken = await _storage.read(key: _kRefreshTokenKey);
    return _cachedRefreshToken;
  }

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    _cachedAccessToken = accessToken;
    _cachedRefreshToken = refreshToken;
    await Future.wait([
      _storage.write(key: _kAccessTokenKey, value: accessToken),
      _storage.write(key: _kRefreshTokenKey, value: refreshToken),
    ]);
  }

  @override
  Future<void> clear() async {
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    await _storage.deleteAll();
  }
}
