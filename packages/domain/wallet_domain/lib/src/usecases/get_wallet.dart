import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// 获取钱包信息的用例接口
abstract interface class GetWallet {
  Future<WalletEntity> call();
}

/// 获取钱包信息的用例实现
class GetWalletImpl implements GetWallet {
  final WalletRepository _repository;

  const GetWalletImpl(this._repository);

  @override
  Future<WalletEntity> call() async {
    return await _repository.getWallet();
  }
}
