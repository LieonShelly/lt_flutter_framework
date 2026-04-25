import '../repositories/repositories.dart';

/// 保存设备 DeviceToken UseCase（用于推送通知）
/// API: POST /api/device-token
abstract interface class SaveDeviceTokenUseCaseType {
  Future<void> execute(String deviceToken);
}

class SaveDeviceTokenUseCase implements SaveDeviceTokenUseCaseType {
  final UserRepository _repository;

  const SaveDeviceTokenUseCase(this._repository);

  @override
  Future<void> execute(String deviceToken) async {
    if (deviceToken.trim().isEmpty) {
      throw ArgumentError('deviceToken 不能为空');
    }
    await _repository.saveDeviceToken(deviceToken);
  }
}
