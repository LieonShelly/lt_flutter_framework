import 'package:wallet_domain/wallet_domain.dart';
import '../datasources/datasources.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource _remoteDataSource;

  const WalletRepositoryImpl(this._remoteDataSource);

  @override
  Future<WalletEntity> getWallet() async {
    final model = await _remoteDataSource.getWallet();
    return model.toEntity();
  }

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    final models = await _remoteDataSource.getTransactions();
    return models.map((m) => m.toEntity()).toList();
  }
}
