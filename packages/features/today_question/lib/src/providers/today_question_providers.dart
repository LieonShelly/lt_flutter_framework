import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'package:reflection_data/reflection_data.dart';


final fethTodayQuestionUseCaseProvider =
    Provider<FetchTodayQuestionUseCaseType>((ref) {
      final repository = ref.watch(reflectionRepositoryProvider);
      return FetchTodayQuestionUseCase(repository);
    });
