import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lt_network/network.dart';
import 'package:wallet_domain/wallet_domain.dart';

import '../datasources/datasources.dart';
import '../repositories/repositories.dart';

final apiClientProvider = Provider<ApiClientType>(
  (ref) => throw UnimplementedError(
    'apiClientProvider must be overridden in App layer',
  ),
  name: 'apiClientProvider',
);

final walletRemoteDataSourceProvider = Provider<WalletRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WalletRemoteDataSourceImpl(apiClient);
}, name: 'walletRemoteDataSourceProvider');

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final dataSource = ref.watch(walletRemoteDataSourceProvider);
  return WalletRepositoryImpl(dataSource);
}, name: 'walletRepositoryProvider');

/// Enable real Binance data source (connects to Binance directly)
final useRealBinanceProvider = Provider<bool>((ref) => false);

final klineRemoteDataSourceProvider = Provider<KlineRemoteDataSource>((ref) {
  return const MockKlineRemoteDataSource();
}, name: 'klineRemoteDataSourceProvider');

final klineStoreProvider = Provider<KlineStore>((ref) {
  return KlineStore();
}, name: 'klineStoreProvider');

final klineRepositoryProvider = Provider<KlineRepository>((ref) {
  final dataSource = ref.watch(klineRemoteDataSourceProvider);
  final store = ref.watch(klineStoreProvider);
  return KlineRepositoryImpl(dataSource, store);
}, name: 'klineRepositoryProvider');
