import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'package:reflection_data/reflection_data.dart';

// ============================================================================
// Today Question Feature - UseCase Providers
// Features 层根据自己的需要创建 UseCase Providers
// ============================================================================

/// 获取今日问题的 UseCase Provider

final fethTodayQuestionUseCaseProvider =
    Provider<FetchTodayQuestionUseCaseType>((ref) {
      final repository = ref.watch(reflectionRepositoryProvider);
      return FetchTodayQuestionUseCase(repository);
    });
