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
