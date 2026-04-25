import '../entities/entities.dart';
import '../repositories/repositories.dart';

/// 设置每日提醒时段 UseCase
/// API: POST /api/me/reminder
/// - 传具体时段（MORNING/AFTERNOON/EVENING）：开启对应时段提醒
/// - 传 null：关闭每日提醒
abstract interface class SetReminderSlotUseCaseType {
  Future<ReminderSlotEntity> execute(ReminderSlot? slot);
}

class SetReminderSlotUseCase implements SetReminderSlotUseCaseType {
  final UserRepository _repository;

  const SetReminderSlotUseCase(this._repository);

  @override
  Future<ReminderSlotEntity> execute(ReminderSlot? slot) async {
    return await _repository.setReminderSlot(slot);
  }
}
