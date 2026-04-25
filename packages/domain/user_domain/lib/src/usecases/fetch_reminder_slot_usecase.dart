import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// 获取每日提醒时段 UseCase
/// API: GET /api/me/reminder
abstract interface class FetchReminderSlotUseCaseType {
  Future<ReminderSlotEntity> execute();
}

class FetchReminderSlotUseCase implements FetchReminderSlotUseCaseType {
  final UserRepository _repository;

  const FetchReminderSlotUseCase(this._repository);

  @override
  Future<ReminderSlotEntity> execute() async {
    return await _repository.fetchReminderSlot();
  }
}
