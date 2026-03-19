import 'package:lt_annotation/annotation.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'category_model.dart';
import 'answer_model.dart';

part 'question_model.lt_model.dart';

@ltDeserialization
class QuestionModel {
  final String id;
  final String title;
  final CategoryModel category;
  final bool? pinned;
  @LtJsonKey('sub_category')
  final CategoryModel? subCategory;
  final List<AnswerModel>? answers;

  QuestionModel({
    required this.id,
    required this.title,
    required this.category,
    this.pinned,
    this.subCategory,
    this.answers,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);

  QuestionEntity toEntity() {
    return QuestionEntity(
      id: id,
      title: title,
      category: category.toEntity(),
      pinned: pinned ?? false,
      subCategory: subCategory?.toEntity(),
      answers: answers?.map((a) => a.toEntity()).toList() ?? [],
    );
  }

  factory QuestionModel.fromEntity(QuestionEntity entity) {
    return QuestionModel(
      id: entity.id,
      title: entity.title,
      category: CategoryModel.fromEntity(entity.category),
      pinned: entity.pinned,
      subCategory: entity.subCategory != null
          ? CategoryModel.fromEntity(entity.subCategory!)
          : null,
      answers: entity.answers.map((a) => AnswerModel.fromEntity(a)).toList(),
    );
  }
}
