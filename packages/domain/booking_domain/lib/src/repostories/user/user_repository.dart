import 'package:booking_domain/booking_domain.dart';
import 'package:common/common.dart';

/// Data source for user related data
abstract class UserRepository {
  /// Get current user
  Future<Result<User>> getUser();
}
