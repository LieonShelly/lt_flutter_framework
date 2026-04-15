import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/generated/answer_detail_api.g.dart',
    swiftOut: 'lib/src/generated/answer_detail_api.g.swift',
    swiftOptions: SwiftOptions(),
    dartPackageName: 'answer_detail_module',
  ),
)
/// 对应 AnswerEntity
class ApiAnswer {
  ApiAnswer({
    required this.id,
    required this.content,
    this.createTms,
    this.createYmd,
    this.question,
    this.icon,
  });

  final String id;
  final String content;
  final String? createTms;
  final String? createYmd;
  final ApiQuestion? question;
  final ApiIcon? icon;
}

/// 对应 QuestionEntity
class ApiQuestion {
  ApiQuestion({
    required this.id,
    required this.title,
    required this.category,
    required this.pinned,
    this.subCategory,
  });

  final String id;
  final String title;
  final ApiCategory category;
  final bool pinned;
  final ApiCategory? subCategory;
}

/// 对应 CategoryEntity
class ApiCategory {
  ApiCategory({required this.id, required this.name, this.color});

  final String id;
  final String name;
  final String? color;
}

/// 对应 IconEntity
class ApiIcon {
  ApiIcon({required this.status, required this.url});

  final String status;
  final String url;
}

/// iOS → Flutter：原生端推送数据给 Flutter
@FlutterApi()
abstract class AnswerDetailFlutterApi {
  void setAnswerData(ApiAnswer answer);
}

/// Flutter → iOS：Flutter 端通知原生端执行操作
@HostApi()
abstract class AnswerDetailHostApi {
  void dismiss();
}
