import 'package:booking_data/booking_data.dart';
import 'package:booking_domain/booking_domain.dart';
import 'package:common/common.dart';

class ContinentRepositoryRemote implements ContinentRepository {
  ContinentRepositoryRemote({required RemoteDatasource apiClient})
    : _apiClient = apiClient;

  final RemoteDatasource _apiClient;

  List<Continent>? _cachedData;

  @override
  Future<Result<List<Continent>>> getContinents() async {
    if (_cachedData == null) {
      // No cached data, request continents
      final result = await _apiClient.getContinents();
      if (result is Ok<List<Continent>>) {
        // Store value if result Ok
        _cachedData = result.value;
      }
      return result;
    } else {
      // Return cached data if available
      return Result.ok(_cachedData!);
    }
  }
}
