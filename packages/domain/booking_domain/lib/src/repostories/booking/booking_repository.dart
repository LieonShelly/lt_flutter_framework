import 'package:booking_domain/booking_domain.dart';
import 'package:common/common.dart';

abstract class BookingRepository {
  /// Returns the list of [BookingSummary] for the current user.
  Future<Result<List<BookingSummary>>> getBookingsList();

  /// Returns a full [Booking] given the id.
  Future<Result<Booking>> getBooking(int id);

  /// Creates a new [Booking].
  Future<Result<void>> createBooking(Booking booking);

  /// Delete booking
  Future<Result<void>> delete(int id);
}
