class WeeklyReportEntity {
  final String id;
  final String week;
  final String periodStart;
  final String periodEnd;
  final int reflectionCount;
  final DateTime? readAt;
  final String? summary;
  final WeeklyReportIconEntity? icon;

  const WeeklyReportEntity({
    required this.id,
    required this.week,
    required this.periodStart,
    required this.periodEnd,
    required this.reflectionCount,
    this.readAt,
    this.summary,
    this.icon,
  });

  bool get isRead => readAt != null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'week': week,
    'period_start': periodStart,
    'period_end': periodEnd,
    'reflection_count': reflectionCount,
    'read_at': readAt?.toIso8601String(),
    'summary': summary,
    'icon': icon?.toJson(),
  };

  factory WeeklyReportEntity.fromJson(Map<String, dynamic> json) =>
      WeeklyReportEntity(
        id: json['id'] as String,
        week: json['week'] as String,
        periodStart: json['period_start'] as String,
        periodEnd: json['period_end'] as String,
        reflectionCount: json['reflection_count'] as int,
        readAt: json['read_at'] != null
            ? DateTime.parse(json['read_at'] as String)
            : null,
        summary: json['summary'] as String?,
        icon: json['icon'] != null
            ? WeeklyReportIconEntity.fromJson(
                json['icon'] as Map<String, dynamic>,
              )
            : null,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyReportEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          week == other.week;

  @override
  int get hashCode => id.hashCode ^ week.hashCode;
}

class WeeklyReportIconEntity {
  final String id;
  final String url;

  const WeeklyReportIconEntity({required this.id, required this.url});

  Map<String, dynamic> toJson() => {'id': id, 'url': url};

  factory WeeklyReportIconEntity.fromJson(Map<String, dynamic> json) =>
      WeeklyReportIconEntity(
        id: json['id'] as String,
        url: json['url'] as String,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyReportIconEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class WeeklyReportListEntity {
  final List<WeeklyReportEntity> reports;
  final PaginationEntity pagination;

  const WeeklyReportListEntity({
    required this.reports,
    required this.pagination,
  });
}

class PaginationEntity {
  final int limit;
  final bool hasMore;
  final String? nextCursor;

  const PaginationEntity({
    required this.limit,
    required this.hasMore,
    this.nextCursor,
  });
}
