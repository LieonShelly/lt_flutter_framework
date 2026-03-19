import '../entities/entities.dart';

abstract interface class ReflectionRepository {
  Future<List<CalendarDayEntity>> fetchCalendarView({
    required DateTime start,
    required DateTime end,
  });

  Future<List<QuestionEntity>> fetchTodayQuestions();

  Future<List<QuestionEntity>> fetchThreadQuestions();

  Future<AnswerEntity> submitAnswer({
    required String questionId,
    required String content,
    String? iconId,
  });

  Future<AnswerEntity> fetchAnswerDetail(String answerId);
}
