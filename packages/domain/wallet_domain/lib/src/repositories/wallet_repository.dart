import '../entities/entities.dart';

abstract interface class WalletRepository {

  Future<WalletEntity> getWallet();

  Future<List<TransactionEntity>> getTransactions();
}
