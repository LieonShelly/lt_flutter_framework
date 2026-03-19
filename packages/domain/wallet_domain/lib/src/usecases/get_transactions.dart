import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// 获取交易记录的用例接口
abstract interface class GetTransactions {
  Future<List<TransactionEntity>> call();
}

/// 获取交易记录的用例实现
class GetTransactionsImpl implements GetTransactions {
  final WalletRepository _repository;

  const GetTransactionsImpl(this._repository);

  @override
  Future<List<TransactionEntity>> call() async {
    return await _repository.getTransactions();
  }
}
