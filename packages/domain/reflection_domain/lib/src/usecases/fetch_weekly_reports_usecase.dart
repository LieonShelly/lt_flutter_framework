import '../entities/entities.dart';
import '../repositories/repositories.dart';

abstract interface class FetchWeeklyReportsUseCaseType {
  Future<WeeklyReportListEntity> execute({
    int? limit,
    String? cursor,
    bool? isRead,
  });
}

class FetchWeeklyReportsUseCase implements FetchWeeklyReportsUseCaseType {
  final ReflectionRepository _repository;

  const FetchWeeklyReportsUseCase(this._repository);

  @override
  Future<WeeklyReportListEntity> execute({
    int? limit,
    String? cursor,
    bool? isRead,
  }) async {
    return await _repository.fetchWeeklyReports(
      limit: limit,
      cursor: cursor,
      isRead: isRead,
    );
  }
}
