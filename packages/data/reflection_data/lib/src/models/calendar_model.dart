import 'package:lt_annotation/annotation.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'answer_model.dart';

part 'calendar_model.lt_model.dart';

@ltDeserialization
class CalendarDayModel {
  final String date;
  final List<AnswerModel> reflections;

  CalendarDayModel({required this.date, required this.reflections});

  factory CalendarDayModel.fromJson(Map<String, dynamic> json) =>
      _$CalendarDayModelFromJson(json);

  CalendarDayEntity toEntity() {
    return CalendarDayEntity(
      date: date,
      answers: reflections.map((r) => r.toEntity()).toList(),
    );
  }

  factory CalendarDayModel.fromEntity(CalendarDayEntity entity) {
    return CalendarDayModel(
      date: entity.date,
      reflections: entity.answers
          .map((a) => AnswerModel.fromEntity(a))
          .toList(),
    );
  }
}

sealed class CalendarDayItemStyle {
  const CalendarDayItemStyle();
}

final class CalendarDayOnlyDateStyle extends CalendarDayItemStyle {
  const CalendarDayOnlyDateStyle();
}

final class CalendarReflectionsStyle extends CalendarDayItemStyle {
  final String date;
  final List<AnswerModel> reflections;
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
