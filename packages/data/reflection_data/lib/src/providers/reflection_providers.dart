import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'package:lt_network/network.dart';
import '../datasources/datasources.dart';
import '../repositories/repositories.dart';

final apiClientProvider = Provider<ApiClientType>(
  (ref) => throw UnimplementedError(
    'apiClientProvider must be overridden in App layer. '
    'Add it to ProviderScope.overrides in main.dart',
  ),
  name: 'apiClientProvider',
);

final chatApiClientProvider = Provider<ApiClientType>(
  (ref) => throw UnimplementedError(
    'chatApiClientProvider must be overridden in App layer. '
    'Add it to ProviderScope.overrides in main.dart',
  ),
  name: 'chatApiClientProvider',
);

final reflectionRemoteDataSourceProvider = Provider<ReflectionRemoteDataSource>(
  (ref) {
    final apiClient = ref.watch(apiClientProvider);
    return ReflectionRemoteDataSourceImpl(apiClient);
  },
  name: 'reflectionRemoteDataSourceProvider',
);

final reflectionRepositoryProvider = Provider<ReflectionRepository>((ref) {
  final dataSource = ref.watch(reflectionRemoteDataSourceProvider);
  return ReflectionRepositoryImpl(dataSource);
}, name: 'reflectionRepositoryProvider');
