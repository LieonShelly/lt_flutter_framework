import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'package:reflection_data/reflection_data.dart';

// ============================================================================
// Calendar Feature - UseCase Providers
// Features 层根据自己的需要创建 UseCase Providers
// ============================================================================

/// 获取日历反思数据的 UseCase Provider
final fetchCalendarReflectionsProvider =
    Provider<CalendarFetchReflectionUseCaseType>((ref) {
      final repository = ref.watch(reflectionRepositoryProvider);
      return CalendarFetchReflectionUseCase(repository: repository);
    });

/// 获取今日问题的 UseCase Provider (Calendar 页面可能也需要)
final fetchTodayQuestionProvider = Provider<FetchTodayQuestionUseCaseType>((
  ref,
) {
  final repository = ref.watch(reflectionRepositoryProvider);
  return FetchTodayQuestionUseCase(repository);
});
