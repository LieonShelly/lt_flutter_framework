import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lt_network/network.dart';
import 'package:reflection_data/reflection_data.dart' as reflection;
import 'package:user_data/user_data.dart' as user;
import 'package:wallet_data/wallet_data.dart' as wallet;

final _tokenStorageProvider = Provider<TokenStorage>((ref) {
  const isProduction = bool.fromEnvironment('dart.vm.product');
  return isProduction ? SecureTokenStorage() : MockTokenStorage();
}, name: '_tokenStorageProvider');

final _mainApiClientProvider = Provider<ApiClientType>((ref) {
  final tokenStorage = ref.watch(_tokenStorageProvider);
  return HttpApiClient(
    baseUrl: 'https://things.dvacode.tech',
    tokenStorage: tokenStorage,
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
