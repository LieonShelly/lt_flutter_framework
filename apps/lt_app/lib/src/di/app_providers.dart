import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lt_network/network.dart';
import 'package:reflection_data/reflection_data.dart';
import 'package:reflection_data/reflection_data.dart' as reflection;
import 'package:user_data/user_data.dart' as user;
import 'package:wallet_data/wallet_data.dart' as wallet;
import 'package:user_domain/user_domain.dart';
import 'package:user_data/user_data.dart' as user_data;

final _tokenStorageProvider = Provider<TokenStorage>((ref) {
  const isProduction = bool.fromEnvironment('dart.vm.product');
  return isProduction ? SecureTokenStorage() : MockTokenStorage();
}, name: '_tokenStorageProvider');

final _tokenRefresherProvider = Provider<TokenRefresher>((ref) {
  final repository = ref.watch(user.userRepositoryProvider);
  final useCase = RefreshTokenUseCase(repository);
  return user_data.UserTokenRefresher(useCase);
}, name: '_tokenRefresherProvider');

final _mainApiClientProvider = Provider<ApiClientType>((ref) {
  final tokenStorage = ref.watch(_tokenStorageProvider);
  final tokenRefresher = ref.watch(_tokenRefresherProvider);
  return HttpApiClient(
    baseUrl: 'https://things.dvacode.tech',
    tokenStorage: tokenStorage,
    tokenRefresher: tokenRefresher,
  );
}, name: '_mainApiClientProvider');

final _chatApiClientProvider = Provider<ApiClientType>((ref) {
  final tokenStorage = ref.watch(_tokenStorageProvider);
  return HttpApiClient(
    baseUrl: NetworkConfig.getChatApiBaseUrl(),
    tokenStorage: tokenStorage,
  );
}, name: '_chatApiClientProvider');

class AppProviders {
  AppProviders._();

  static dynamic get overrides => [
    reflection.apiClientProvider.overrideWith((ref) {
      return ref.watch(_mainApiClientProvider);
    }),
    reflection.chatApiClientProvider.overrideWith((ref) {
      return ref.watch(_chatApiClientProvider);
    }),

    user.apiClientProvider.overrideWith((ref) {
      return ref.watch(_mainApiClientProvider);
    }),

    wallet.apiClientProvider.overrideWith((ref) {
      return ref.watch(_mainApiClientProvider);
    }),
  ];
}
