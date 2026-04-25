/// Token 刷新契约（Core 层定义，Data 层实现）
///
/// 遵循依赖倒置原则（DIP）：
/// - Core 层只依赖此抽象，不感知 UseCase / Repository
/// - Data 层的 UserRepository 实现此接口
/// - App 层在 DI 配置中将实现注入给 RefreshTokenInterceptor
abstract interface class TokenRefresher {
  /// 使用 refreshToken 换取新的 Token 对。
  /// 成功时返回 (newAccessToken, newRefreshToken)。
  /// 失败时抛出异常。
  Future<(String accessToken, String refreshToken)> refresh(
    String refreshToken,
  );
}
