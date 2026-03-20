import 'package:booking_domain/booking_domain.dart';
import 'package:common/common.dart';

/// Data source with all possible continents.
abstract class ContinentRepository {
  /// Get complete list of continents.
  Future<Result<List<Continent>>> getContinents();
}
