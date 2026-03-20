import 'package:booking_domain/booking_domain.dart';
import 'package:common/common.dart';

abstract class ActivityRepository {
  Future<Result<List<Activity>>> getByDestination(String ref);
}
