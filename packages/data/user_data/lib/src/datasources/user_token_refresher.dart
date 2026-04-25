import 'package:lt_network/network.dart';
import 'package:user_domain/user_domain.dart';

class UserTokenRefresher implements TokenRefresher {
  final RefreshTokenUseCaseType _useCase;

  UserTokenRefresher(this._useCase);

  Future<(String, String)>? _pendingRefresh;

  @override
  Future<(String, String)> refresh(String refreshToken) {
    _pendingRefresh ??= _doRefresh(refreshToken).whenComplete(() {
      _pendingRefresh = null;
    });
    return _pendingRefresh!;
  }

  Future<(String, String)> _doRefresh(String refreshToken) async {
    final AuthEntity auth = await _useCase.execute(refreshToken: refreshToken);
    return (auth.accessToken, auth.refreshToken);
  }
}
