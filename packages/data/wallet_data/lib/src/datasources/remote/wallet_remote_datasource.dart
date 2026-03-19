import 'package:lt_network/network.dart';
import '../../models/models.dart';

/// 钱包相关的远程数据源接口
abstract interface class WalletRemoteDataSource {
  Future<WalletModel> getWallet();
  Future<List<TransactionModel>> getTransactions();
}

/// 钱包相关的远程数据源实现
class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final ApiClientType _apiClient;

  const WalletRemoteDataSourceImpl(this._apiClient);

  @override
  Future<WalletModel> getWallet() async {
    final response = await _apiClient.get('/api/wallet');
    return WalletModel.fromJson(response['data']);
  }

  @override
  Future<List<TransactionModel>> getTransactions() async {
    final response = await _apiClient.get('/api/wallet/transactions');
    final data = response['data'] as List;
    return data.map((json) => TransactionModel.fromJson(json)).toList();
  }
}
