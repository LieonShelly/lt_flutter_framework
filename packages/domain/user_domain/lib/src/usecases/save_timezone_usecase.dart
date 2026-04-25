import '../repositories/repositories.dart';

/// 保存用户时区 UseCase
/// API: POST /api/timezone
/// 接受 ISO 8601 带 UTC 偏移的时间戳（如 "2026-04-05T09:00:00+08:00"）
abstract interface class SaveTimezoneUseCaseType {
  Future<void> execute(String timestamp);
}

class SaveTimezoneUseCase implements SaveTimezoneUseCaseType {
  final UserRepository _repository;

  const SaveTimezoneUseCase(this._repository);

  @override
  Future<void> execute(String timestamp) async {
    if (timestamp.trim().isEmpty) {
      throw ArgumentError('timestamp 不能为空');
    }
    // 简单校验：必须包含 UTC 偏移符号
    final hasOffset =
        timestamp.contains('+') || timestamp.contains('-', 10);
    if (!hasOffset) {
      throw ArgumentError('timestamp 必须包含 UTC 偏移（如 +08:00 或 -05:00）');
    }
    await _repository.saveTimezone(timestamp);
  }
}
