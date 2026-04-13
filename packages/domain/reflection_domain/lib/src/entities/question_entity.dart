import 'category_entity.dart';
import 'answer_entity.dart';

class QuestionEntity {
  final String id;
  final String title;
  final CategoryEntity category;
  final bool pinned;
  final CategoryEntity? subCategory;
  final List<AnswerEntity> answers;

  const QuestionEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.pinned,
    this.subCategory,
    required this.answers,
  });

  Map<String, dynamic> toJson({bool includeAnswers = true}) => {
    'id': id,
    'title': title,
    'category': category.toJson(),
    'pinned': pinned,
    'subCategory': subCategory?.toJson(),
    if (includeAnswers) 'answers': answers.map((a) => a.toJson()).toList(),
  };

  factory QuestionEntity.fromJson(Map<String, dynamic> json) => QuestionEntity(
    id: json['id'] as String,
    title: json['title'] as String,
    category: CategoryEntity.fromJson(json['category'] as Map<String, dynamic>),
    pinned: json['pinned'] as bool,
    subCategory: json['subCategory'] != null
        ? CategoryEntity.fromJson(json['subCategory'] as Map<String, dynamic>)
        : null,
    answers:
        (json['answers'] as List<dynamic>?)
            ?.map((e) => AnswerEntity.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );

  bool get hasAnswers => answers.isNotEmpty;

  bool get isAnsweredToday {
    if (answers.isEmpty) return false;
    final today = DateTime.now();
    return answers.any((a) => _isSameDay(a.createYmd!, today));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          pinned == other.pinned;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ pinned.hashCode;
}
