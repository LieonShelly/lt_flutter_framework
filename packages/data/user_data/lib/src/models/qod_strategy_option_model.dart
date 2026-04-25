import 'package:user_domain/user_domain.dart';

/// QoD 策略选项 DTO
/// 对应 GET /api/qod-strategy-options 数组元素
class QodStrategyOptionModel {
  final String value;
  final String label;
  final String description;
  final bool disabled;
  final String? url;

  QodStrategyOptionModel({
    required this.value,
    required this.label,
    required this.description,
    required this.disabled,
    this.url,
  });

  factory QodStrategyOptionModel.fromJson(Map<String, dynamic> json) {
    return QodStrategyOptionModel(
      value: json['value'] as String,
      label: json['label'] as String,
      description: json['description'] as String,
      disabled: json['disabled'] as bool? ?? false,
      url: json['url'] as String?,
    );
  }

  QodStrategyOptionEntity toEntity() {
    return QodStrategyOptionEntity(
      value: QodStrategy.fromString(value),
      label: label,
      description: description,
      disabled: disabled,
      iconUrl: url,
    );
  }
}
