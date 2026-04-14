import 'package:lt_annotation/annotation.dart';
import 'package:reflection_domain/reflection_domain.dart';

part 'weekly_report_model.lt_model.dart';

@ltDeserialization
class WeeklyReportModel {
  final String id;
  final String week;
  @LtJsonKey('period_start')
  final String periodStart;
  @LtJsonKey('period_end')
  final String periodEnd;
  @LtJsonKey('reflection_count')
  final int reflectionCount;
  @LtJsonKey('read_at')
  final String? readAt;
  final String? summary;
  final WeeklyReportIconModel? icon;

  WeeklyReportModel({
    required this.id,
    required this.week,
    required this.periodStart,
    required this.periodEnd,
    required this.reflectionCount,
    this.readAt,
    this.summary,
    this.icon,
  });

  factory WeeklyReportModel.fromJson(Map<String, dynamic> json) =>
      _$WeeklyReportModelFromJson(json);

  WeeklyReportEntity toEntity() {
    return WeeklyReportEntity(
      id: id,
      week: week,
      periodStart: periodStart,
      periodEnd: periodEnd,
      reflectionCount: reflectionCount,
      readAt: readAt != null ? DateTime.parse(readAt!) : null,
      summary: summary,
      icon: icon?.toEntity(),
    );
  }

  factory WeeklyReportModel.fromEntity(WeeklyReportEntity entity) {
    return WeeklyReportModel(
      id: entity.id,
      week: entity.week,
      periodStart: entity.periodStart,
      periodEnd: entity.periodEnd,
      reflectionCount: entity.reflectionCount,
      readAt: entity.readAt?.toIso8601String(),
      summary: entity.summary,
      icon: entity.icon != null
          ? WeeklyReportIconModel.fromEntity(entity.icon!)
          : null,
    );
  }
}

@ltDeserialization
class WeeklyReportIconModel {
  final String id;
  final String url;

  WeeklyReportIconModel({required this.id, required this.url});

  factory WeeklyReportIconModel.fromJson(Map<String, dynamic> json) =>
      _$WeeklyReportIconModelFromJson(json);

  WeeklyReportIconEntity toEntity() {
    return WeeklyReportIconEntity(id: id, url: url);
  }

  factory WeeklyReportIconModel.fromEntity(WeeklyReportIconEntity entity) {
    return WeeklyReportIconModel(id: entity.id, url: entity.url);
  }
}

@ltDeserialization
class WeeklyReportListModel {
  final List<WeeklyReportModel> reports;
  final PaginationModel pagination;

  WeeklyReportListModel({required this.reports, required this.pagination});

  factory WeeklyReportListModel.fromJson(Map<String, dynamic> json) =>
      _$WeeklyReportListModelFromJson(json);

  WeeklyReportListEntity toEntity() {
    return WeeklyReportListEntity(
      reports: reports.map((r) => r.toEntity()).toList(),
      pagination: pagination.toEntity(),
    );
  }
}

@ltDeserialization
class PaginationModel {
  final int limit;
  final bool hasMore;
  final String? nextCursor;

  PaginationModel({
    required this.limit,
    required this.hasMore,
    this.nextCursor,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) =>
      _$PaginationModelFromJson(json);

  PaginationEntity toEntity() {
    return PaginationEntity(
      limit: limit,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
  }
}
