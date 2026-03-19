import '../entities/entities.dart';
import '../repositories/repositories.dart';

abstract interface class GetTransactions {
  Future<List<TransactionEntity>> call();
}

class GetTransactionsImpl implements GetTransactions {
  final WalletRepository _repository;

  const GetTransactionsImpl(this._repository);

  @override
  Future<List<TransactionEntity>> call() async {
    return await _repository.getTransactions();
  }
}
