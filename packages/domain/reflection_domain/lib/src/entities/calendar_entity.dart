import 'answer_entity.dart';

class CalendarDayEntity {
  final String date;
  final List<AnswerEntity> answers;

  const CalendarDayEntity({required this.date, required this.answers});

  bool get hasReflection => answers.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarDayEntity &&
          runtimeType == other.runtimeType &&
          date == other.date;

  @override
  int get hashCode => date.hashCode;
}

sealed class CalendarDayItemStyle {
  const CalendarDayItemStyle();
}

final class CalendarDayOnlyDateStyle extends CalendarDayItemStyle {
  const CalendarDayOnlyDateStyle();
}

final class CalendarReflectionsStyle extends CalendarDayItemStyle {
  final String date;
  final List<AnswerEntity> reflections;
  const CalendarReflectionsStyle(this.date, this.reflections);
}

final class CalendarDayDashlineStyle extends CalendarDayItemStyle {
  const CalendarDayDashlineStyle();
}

class CalendarDayItem {
  final String date;
  final CalendarDayItemStyle style;

  const CalendarDayItem({required this.date, required this.style});
}
