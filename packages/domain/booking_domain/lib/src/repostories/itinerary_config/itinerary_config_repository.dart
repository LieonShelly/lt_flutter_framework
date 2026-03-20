import 'package:booking_domain/booking_domain.dart';
import 'package:common/common.dart';

/// Data source for the current [ItineraryConfig]
abstract class ItineraryConfigRepository {
  /// Get current [ItineraryConfig], may be empty if no configuration started.
  /// Method is async to support writing to database, file, etc.
  Future<Result<ItineraryConfig>> getItineraryConfig();

  /// Sets [ItineraryConfig], overrides the previous one stored.
  /// Returns Result.Ok if set is successful.
  Future<Result<void>> setItineraryConfig(ItineraryConfig itineraryConfig);
}
