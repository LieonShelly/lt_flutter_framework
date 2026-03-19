import 'package:reflection_domain/reflection_domain.dart';
import 'package:reflection_data/reflection_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final submitAnswerUsecaseProvider = Provider<SubmitAnswerUseCaseType>((ref) {
  final repository = ref.watch(reflectionRepositoryProvider);
  return SubmitAnswerUseCase(repository);
});
