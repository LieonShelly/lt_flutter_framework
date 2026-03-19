import '../entities/entities.dart';

/// 反思相关的数据仓储接口
abstract interface class ReflectionRepository {
  /// 获取日历视图数据
  Future<List<CalendarDayEntity>> fetchCalendarView({
    required DateTime start,
    required DateTime end,
  });

  /// 获取今日问题
  Future<List<QuestionEntity>> fetchTodayQuestions();

  /// 获取 Thread 问题列表
  Future<List<QuestionEntity>> fetchThreadQuestions();

  /// 提交答案
  Future<AnswerEntity> submitAnswer({
    required String questionId,
    required String content,
    String? iconId,
  });

  /// 获取答案详情
  Future<AnswerEntity> fetchAnswerDetail(String answerId);
}
