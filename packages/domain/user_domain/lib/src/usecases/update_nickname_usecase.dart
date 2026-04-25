import '../repositories/repositories.dart';

/// 更新用户昵称 UseCase
/// API: POST /api/me
/// - 传字符串：更新昵称（超长或类型非法会 400）
/// - 传 null：清空昵称
abstract interface class UpdateNicknameUseCaseType {
  Future<void> execute(String? nickname);
}

class UpdateNicknameUseCase implements UpdateNicknameUseCaseType {
  final UserRepository _repository;

  const UpdateNicknameUseCase(this._repository);

  @override
  Future<void> execute(String? nickname) async {
    if (nickname != null && nickname.length > 64) {
      throw ArgumentError('昵称长度不能超过 64 个字符');
    }
    await _repository.updateNickname(nickname);
  }
}
