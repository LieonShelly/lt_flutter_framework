import '../entities/entities.dart';
import '../repositories/repositories.dart';

abstract interface class GetWallet {
  Future<WalletEntity> call();
}

class GetWalletImpl implements GetWallet {
  final WalletRepository _repository;

  const GetWalletImpl(this._repository);

  @override
  Future<WalletEntity> call() async {
    return await _repository.getWallet();
  }
}
