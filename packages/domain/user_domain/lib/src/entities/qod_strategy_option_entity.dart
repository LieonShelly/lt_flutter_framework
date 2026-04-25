/// 今日问题（QoD）策略枚举
enum QodStrategy {
  random,
  pinned,
  mixed;

  static QodStrategy fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PINNED':
        return QodStrategy.pinned;
      case 'MIXED':
        return QodStrategy.mixed;
      default:
        return QodStrategy.random;
    }
  }

  String toApiString() => name.toUpperCase();
}

/// QoD 策略选项实体（来自 GET /api/qod-strategy-options）
class QodStrategyOptionEntity {
  final QodStrategy value;
  final String label;
  final String description;
  final bool disabled;
  final String? iconUrl;

  const QodStrategyOptionEntity({
    required this.value,
    required this.label,
    required this.description,
    required this.disabled,
    this.iconUrl,
  });
}
