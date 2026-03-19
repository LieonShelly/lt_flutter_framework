import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'package:reflection_data/reflection_data.dart';

final fetchCalendarReflectionsProvider =
    Provider<CalendarFetchReflectionUseCaseType>((ref) {
      final repository = ref.watch(reflectionRepositoryProvider);
      return CalendarFetchReflectionUseCase(repository: repository);
    });

final fetchTodayQuestionProvider = Provider<FetchTodayQuestionUseCaseType>((
  ref,
) {
  final repository = ref.watch(reflectionRepositoryProvider);
  return FetchTodayQuestionUseCase(repository);
});
