import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet_domain/wallet_domain.dart';
import 'package:lt_network/network.dart';
import '../datasources/datasources.dart';
import '../repositories/repositories.dart';

// ============================================================================
// Wallet Data Layer - Dependency Injection
// 只包含 DataSource 和 Repository Providers
// UseCase Providers 由 Features 层根据需要创建
// ============================================================================

// DataSource Provider
final walletRemoteDataSourceProvider = Provider<WalletRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WalletRemoteDataSourceImpl(apiClient);
});

// Repository Provider
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final dataSource = ref.watch(walletRemoteDataSourceProvider);
  return WalletRepositoryImpl(dataSource);
});
