import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'package:reflection_data/reflection_data.dart';

// ============================================================================
// Thread Feature - UseCase Providers
// Features 层根据自己的需要创建 UseCase Providers
// ============================================================================

/// 获取 Thread 问题列表的 UseCase Provider

final fetchThreadQuestionsUseCaseProvider =
    Provider<FetchThreadQuestionsUseCaseType>((ref) {
      final repository = ref.watch(reflectionRepositoryProvider);
      final usecase = FetchThreadQuestionsUseCase(repository);
      return usecase;
    });
