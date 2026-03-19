import 'package:reflection_domain/reflection_domain.dart';
import '../datasources/datasources.dart';

/// 反思相关的数据仓储实现
class ReflectionRepositoryImpl implements ReflectionRepository {
  final ReflectionRemoteDataSource _remoteDataSource;

  const ReflectionRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<CalendarDayEntity>> fetchCalendarView({
    required DateTime start,
    required DateTime end,
  }) async {
    final models = await _remoteDataSource.fetchCalendarView(
      start: start,
      end: end,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<QuestionEntity>> fetchThreadQuestions() async {
    final models = await _remoteDataSource.fetchThreadQuestions();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<QuestionEntity>> fetchTodayQuestions() async {
    final models = await _remoteDataSource.fetchTodayQuestions();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<AnswerEntity> submitAnswer({
    required String questionId,
    required String content,
    String? iconId,
  }) async {
    final model = await _remoteDataSource.submitAnswer(
      questionId: questionId,
      content: content,
      iconId: iconId,
    );
    return model.toEntity();
  }

  @override
  Future<AnswerEntity> fetchAnswerDetail(String answerId) async {
    final model = await _remoteDataSource.fetchAnswerDetail(answerId);
    return model.toEntity();
  }
}
