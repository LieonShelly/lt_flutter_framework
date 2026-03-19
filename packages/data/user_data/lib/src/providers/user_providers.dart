import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_domain/user_domain.dart';
import 'package:lt_network/network.dart';
import '../datasources/datasources.dart';
import '../repositories/repositories.dart';

// ============================================================================
// User Data Layer - Dependency Injection
// 只包含 DataSource 和 Repository Providers
// UseCase Providers 由 Features 层根据需要创建
// ============================================================================

// DataSource Provider
final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserRemoteDataSourceImpl(apiClient);
});

// Repository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dataSource = ref.watch(userRemoteDataSourceProvider);
  return UserRepositoryImpl(dataSource);
});
