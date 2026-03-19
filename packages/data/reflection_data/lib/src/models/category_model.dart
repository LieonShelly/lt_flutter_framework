import 'package:lt_annotation/annotation.dart';
import 'package:reflection_domain/reflection_domain.dart';

part 'category_model.lt_model.dart';

@ltDeserialization
class CategoryModel {
  final String? id;
  final String name;
  final String? color;

  CategoryModel({this.id, required this.name, this.color});

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  CategoryEntity toEntity() {
    return CategoryEntity(id: id ?? '', name: name, color: color);
  }

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(id: entity.id, name: entity.name, color: entity.color);
  }
}
