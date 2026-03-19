import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_domain/user_domain.dart';
import 'package:lt_network/network.dart';
import '../datasources/datasources.dart';
import '../repositories/repositories.dart';

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserRemoteDataSourceImpl(apiClient);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dataSource = ref.watch(userRemoteDataSourceProvider);
  return UserRepositoryImpl(dataSource);
});
