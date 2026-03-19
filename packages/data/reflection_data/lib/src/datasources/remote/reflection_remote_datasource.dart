import 'package:lt_network/network.dart';
import '../../models/models.dart';

/// 反思相关的远程数据源接口
abstract interface class ReflectionRemoteDataSource {
  Future<List<CalendarDayModel>> fetchCalendarView({
    required DateTime start,
    required DateTime end,
  });

  Future<List<QuestionModel>> fetchTodayQuestions();
  Future<List<QuestionModel>> fetchThreadQuestions();

  Future<AnswerModel> submitAnswer({
    required String questionId,
    required String content,
    String? iconId,
  });

  Future<AnswerModel> fetchAnswerDetail(String answerId);
}

/// 反思相关的远程数据源实现
class ReflectionRemoteDataSourceImpl implements ReflectionRemoteDataSource {
  final ApiClientType _apiClient;

  const ReflectionRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<CalendarDayModel>> fetchCalendarView({
    required DateTime start,
    required DateTime end,
  }) async {
    final response = await _apiClient.get(
      '/api/calendar-view',
      queryParameters: {
        'start': start.toIso8601String().split('T')[0],
        'end': end.toIso8601String().split('T')[0],
      },
    );

    final data = response['data'] as List;
    return await ComputeTransformer.decodeList(data, CalendarDayModel.fromJson);
  }

  @override
  Future<List<QuestionModel>> fetchThreadQuestions() async {
    final response = await _apiClient.get('/api/thread-view');
    final data = response['data'];
    if (data is List) {
      return await ComputeTransformer.decodeList(data, QuestionModel.fromJson);
    }
    return [];
  }

  @override
  Future<List<QuestionModel>> fetchTodayQuestions() async {
    final response = await _apiClient.get('/api/qod');
    final data = response['data'];
    if (data is List) {
      return await ComputeTransformer.decodeList(data, QuestionModel.fromJson);
    }
    return [];
  }

  @override
  Future<AnswerModel> submitAnswer({
    required String questionId,
    required String content,
    String? iconId,
  }) async {
    final response = await _apiClient.post(
      '/api/answers',
      data: {
        'question_id': questionId,
        'content': content,
        if (iconId != null) 'icon_id': iconId,
      },
    );

    return AnswerModel.fromJson(response['data']);
  }

  @override
  Future<AnswerModel> fetchAnswerDetail(String answerId) async {
    final response = await _apiClient.get('/api/answers/$answerId');
    return AnswerModel.fromJson(response['data']);
  }
}
