import '../network_core/token_storage.dart';

class MockTokenStorage implements TokenStorage {
  @override
  Future<String?> getAccessToken() async {
    return r" eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjbWdyam1tN20wMDAwcHBweHZoZXhuMm1tIiwiYXBwbGVJZCI6IjAwMTc3NC5mYjZiNjFiMjk5MmU0NjgzOGJlZTM0ZTc4MWE2YTExNC4xMDIxIiwidHlwZSI6ImFjY2VzcyIsImlhdCI6MTc3NTYyMDkwNSwiZXhwIjoxNzc1NzA3MzA1fQ.lPxBy7YMz5o2YrtTrxUFCmzsNSccLd1KbjjqRnL2bP0";
  }

  @override
  Future<String?> getRefreshToken() async {
    return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjbWdyam1tN20wMDAwcHBweHZoZXhuMm1tIiwiYXBwbGVJZCI6IjAwMTc3NC5mYjZiNjFiMjk5MmU0NjgzOGJlZTM0ZTc4MWE2YTExNC4xMDIxIiwidHlwZSI6InJlZnJlc2giLCJpYXQiOjE3NjgyMDE5NTksImV4cCI6MTc2OTQ5Nzk1OX0.EsU9be5lIHnnmzj2CYMS3g8ZgCU3t9vXyQx9Ssnoy1E";
  }

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {}

  @override
  Future<void> clear() async {}
}
