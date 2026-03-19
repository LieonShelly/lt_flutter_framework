// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_model.dart';

// **************************************************************************
// LtDeserializationGenerator
// **************************************************************************

CalendarDayModel _$CalendarDayModelFromJson(Map<String, dynamic> json) {
  return CalendarDayModel(
    date: json['date'] as String,
    reflections: (json['reflections'] as List)
        .map((e) => AnswerModel.fromJson(e))
        .toList(),
  );
}
