import '../entities/entities.dart';

/// 钱包相关的数据仓储接口
abstract interface class WalletRepository {
  /// 获取钱包信息
  Future<WalletEntity> getWallet();

  /// 获取交易记录
  Future<List<TransactionEntity>> getTransactions();
}
