import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet_data/wallet_data.dart';
import 'package:wallet_domain/wallet_domain.dart';

/// App-level override for klineRepositoryProvider to use mock data source
final appKlineRepositoryProvider = Provider<KlineRepository>((ref) {
  const dataSource = MockKlineRemoteDataSource();
  final store = KlineStore();
  return KlineRepositoryImpl(dataSource, store);
});

class AppProviders {
  AppProviders._();
}
