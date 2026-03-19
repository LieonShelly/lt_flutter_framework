// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_model.dart';

// **************************************************************************
// LtDeserializationGenerator
// **************************************************************************

QuestionModel _$QuestionModelFromJson(Map<String, dynamic> json) {
  return QuestionModel(
    id: json['id'] as String,
    title: json['title'] as String,
    category: CategoryModel.fromJson(json['category']),
    pinned: json['pinned'] as bool?,
    subCategory: json['sub_category'] == null
        ? null
        : CategoryModel.fromJson(json['sub_category']),
    answers: json['answers'] == null
        ? null
        : (json['answers'] as List)
              .map((e) => AnswerModel.fromJson(e))
              .toList(),
  );
}
