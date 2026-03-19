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

  bool get hasAnswers => answers.isNotEmpty;

  bool get isAnsweredToday {
    if (answers.isEmpty) return false;
    final today = DateTime.now();
    return answers.any((a) => _isSameDay(a.createdAt, today));
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
