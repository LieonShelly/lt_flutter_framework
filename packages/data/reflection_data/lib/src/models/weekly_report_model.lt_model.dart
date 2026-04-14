// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_report_model.dart';

// **************************************************************************
// LtDeserializationGenerator
// **************************************************************************

WeeklyReportModel _$WeeklyReportModelFromJson(Map<String, dynamic> json) {
  return WeeklyReportModel(
    id: json['id'] as String,
    week: json['week'] as String,
    periodStart: json['period_start'] as String,
    periodEnd: json['period_end'] as String,
    reflectionCount: json['reflection_count'] as int,
    readAt: json['read_at'] as String?,
    summary: json['summary'] as String?,
    icon: json['icon'] == null
        ? null
        : WeeklyReportIconModel.fromJson(json['icon']),
  );
}

WeeklyReportIconModel _$WeeklyReportIconModelFromJson(
  Map<String, dynamic> json,
) {
  return WeeklyReportIconModel(
    id: json['id'] as String,
    url: json['url'] as String,
  );
}

WeeklyReportListModel _$WeeklyReportListModelFromJson(
  Map<String, dynamic> json,
) {
  return WeeklyReportListModel(
    reports: (json['reports'] as List)
        .map((e) => WeeklyReportModel.fromJson(e))
        .toList(),
    pagination: PaginationModel.fromJson(json['pagination']),
  );
}

PaginationModel _$PaginationModelFromJson(Map<String, dynamic> json) {
  return PaginationModel(
    limit: json['limit'] as int,
    hasMore: json['has_more'] as bool,
    nextCursor: json['next_cursor'] as String?,
  );
}
