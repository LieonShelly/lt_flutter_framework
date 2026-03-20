import 'package:booking_domain/booking_domain.dart';
import 'package:common/common.dart';

/// Data source with all possible destinations
abstract class DestinationRepository {
  /// Get complete list of destinations
  Future<Result<List<Destination>>> getDestinations();
}
