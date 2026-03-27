import 'dart:async';

abstract interface class ContractDataSource {
  Future<double> fetchCustomBalance(String userAddress, String contractAddress);
}
