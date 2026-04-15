import 'generated/answer_detail_api.g.dart';
import 'package:reflection_domain/reflection_domain.dart';

/// ApiAnswer → AnswerEntity 转换
extension ApiAnswerConverter on ApiAnswer {
  AnswerEntity toAnswerEntity() => AnswerEntity(
    id: id,
    content: content,
    createTms: _tryParseDateTime(createTms),
    createYmd: _tryParseDateTime(createYmd),
    question: question?.toQuestionEntity(),
    icon: icon?.toIconEntity(),
  );
}

/// ApiQuestion → QuestionEntity 转换
extension ApiQuestionConverter on ApiQuestion {
  QuestionEntity toQuestionEntity() => QuestionEntity(
    id: id,
    title: title,
    category: category.toCategoryEntity(),
    pinned: pinned,
    subCategory: subCategory?.toCategoryEntity(),
    answers: const [],
  );
}

/// ApiCategory → CategoryEntity 转换
extension ApiCategoryConverter on ApiCategory {
  CategoryEntity toCategoryEntity() =>
      CategoryEntity(id: id, name: name, color: color);
}

/// ApiIcon → IconEntity 转换
extension ApiIconConverter on ApiIcon {
  IconEntity toIconEntity() =>
      IconEntity(status: IconStatus.fromString(status.toUpperCase()), url: url);
}

/// 安全解析 DateTime 字符串，处理 null、空字符串和无效格式
DateTime? _tryParseDateTime(String? value) {
  if (value == null || value.isEmpty) return null;
  return DateTime.tryParse(value);
}
