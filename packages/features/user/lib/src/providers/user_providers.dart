import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_domain/user_domain.dart';
import 'package:user_data/user_data.dart';

/// Apple 登录 UseCase Provider
final loginWithAppleProvider = Provider<LoginWithAppleUseCaseType>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return LoginWithAppleUseCase(repository);
});

/// Google 登录 UseCase Provider
final loginWithGoogleProvider = Provider<LoginWithGoogleUseCaseType>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return LoginWithGoogleUseCase(repository);
});

/// 刷新 Token UseCase Provider
final refreshTokenProvider = Provider<RefreshTokenUseCaseType>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return RefreshTokenUseCase(repository);
});

// ─── 用户设置 UseCase Providers ───────────────────────────────────────────────

/// 保存设备 Token UseCase Provider
final saveDeviceTokenProvider = Provider<SaveDeviceTokenUseCaseType>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return SaveDeviceTokenUseCase(repository);
});

/// 保存用户时区 UseCase Provider
final saveTimezoneProvider = Provider<SaveTimezoneUseCaseType>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return SaveTimezoneUseCase(repository);
});

/// 更新 QoD 策略 UseCase Provider
final updateQodStrategyProvider = Provider<UpdateQodStrategyUseCaseType>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UpdateQodStrategyUseCase(repository);
});

/// 获取 QoD 策略选项 UseCase Provider
final fetchQodStrategyOptionsProvider =
    Provider<FetchQodStrategyOptionsUseCaseType>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return FetchQodStrategyOptionsUseCase(repository);
});

/// 获取个人信息 UseCase Provider
final fetchMeProvider = Provider<FetchMeUseCaseType>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return FetchMeUseCase(repository);
});

/// 更新昵称 UseCase Provider
final updateNicknameProvider = Provider<UpdateNicknameUseCaseType>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return UpdateNicknameUseCase(repository);
});

/// 获取每日提醒时段 UseCase Provider
final fetchReminderSlotProvider = Provider<FetchReminderSlotUseCaseType>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return FetchReminderSlotUseCase(repository);
});

/// 设置每日提醒时段 UseCase Provider
final setReminderSlotProvider = Provider<SetReminderSlotUseCaseType>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return SetReminderSlotUseCase(repository);
});
