import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet_domain/wallet_domain.dart';
import 'package:lt_network/network.dart';
import '../datasources/datasources.dart';
import '../repositories/repositories.dart';

final walletRemoteDataSourceProvider = Provider<WalletRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WalletRemoteDataSourceImpl(apiClient);
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final dataSource = ref.watch(walletRemoteDataSourceProvider);
  return WalletRepositoryImpl(dataSource);
});
