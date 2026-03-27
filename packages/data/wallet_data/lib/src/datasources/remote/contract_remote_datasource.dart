import 'package:wallet_data/wallet_data.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

class ContractRemoteDataSource implements ContractDataSource {
  late final Web3Client _web3client;

  ContractRemoteDataSource() {
    _web3client = Web3Client(
      'https://eth-mainnet.g.alchemy.com/v2/YOUR_ALCHEMY_API_KEY',
      http.Client(),
    );
  }

  static const String _minmalErc20Abi = '''[
    {
      "constant": true,
      "inputs": [{"name": "_owner", "type": "address"}],
      "name": "balanceOf",
      "outputs": [{"name": "balance", "type": "uint256"}],
      "type": "function"
    },
    {
      "constant": true,
      "inputs": [],
      "name": "decimals",
      "outputs": [{"name": "", "type": "uint8"}],
      "type": "function"
    }
  ]''';

  @override
  Future<double> fetchCustomBalance(
    String userAddress,
    String contractAddress,
  ) async {
    final contract = DeployedContract(
      ContractAbi.fromJson(_minmalErc20Abi, 'ERC20_Minimal'),
      EthereumAddress.fromHex(contractAddress),
    );

    final balanceOfFunction = contract.function('balanceOf');
    final decimalsFunction = contract.function('decimals');
    final etherUserAddress = EthereumAddress.fromHex(userAddress);

    final results = await Future.wait([
      _web3client.call(
        contract: contract,
        function: decimalsFunction,
        params: [],
      ),
      _web3client.call(
        contract: contract,
        function: balanceOfFunction,
        params: [etherUserAddress],
      ),
    ]);

    final BigInt decimalsRaw = results[0].first as BigInt;
    final int decimals = decimalsRaw.toInt();

    final BigInt rawBalance = results[1].first as BigInt;

    final divisor = BigInt.from(10).pow(decimals);

    return rawBalance / divisor;
  }
}
