import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'package:lt_network/network.dart';
import '../datasources/datasources.dart';
import '../repositories/repositories.dart';

// ============================================================================
// Reflection Data Layer - Dependency Injection
// 只包含 DataSource 和 Repository Providers
// UseCase Providers 由 Features 层根据需要创建
// ============================================================================

// DataSource Provider
final reflectionRemoteDataSourceProvider = Provider<ReflectionRemoteDataSource>(
  (ref) {
    final apiClient = ref.watch(apiClientProvider);
    return ReflectionRemoteDataSourceImpl(apiClient);
  },
);

// Repository Provider
final reflectionRepositoryProvider = Provider<ReflectionRepository>((ref) {
  final dataSource = ref.watch(reflectionRemoteDataSourceProvider);
  return ReflectionRepositoryImpl(dataSource);
});
