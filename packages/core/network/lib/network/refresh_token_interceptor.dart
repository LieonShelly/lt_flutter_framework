import 'package:dio/dio.dart';
import '../network_core/token_refresher.dart';
import '../network_core/token_storage.dart';

class RefreshTokenInterceptor extends Interceptor {
  final Dio _dio;
  final TokenStorage _storage;
  final TokenRefresher _tokenRefresher;

  RefreshTokenInterceptor(this._dio, this._storage, this._tokenRefresher);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }
    if (err.requestOptions.path.contains('/auth/refresh')) {
      await _storage.clear();
      return handler.next(err);
    }
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) {
        return handler.next(err);
      }

      // 通过注入的抽象接口完成 Token 刷新，不依赖具体实现
      final (newAccessToken, newRefreshToken) =
          await _tokenRefresher.refresh(refreshToken);

      await _storage.saveTokens(newAccessToken, newRefreshToken);

      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newAccessToken';
      final cloneReq = await _dio.fetch(opts);
      return handler.resolve(cloneReq);
    } on DioException catch (e) {
      await _storage.clear();
      return handler.next(e);
    } catch (e) {
      return handler.next(err);
    }
  }
}
