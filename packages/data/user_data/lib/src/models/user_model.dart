import 'package:lt_annotation/annotation.dart';
import 'package:user_domain/user_domain.dart';

part 'user_model.lt_model.dart';

@ltDeserialization
class UserModel {
  final String id;
  final String name;
  final String? email;
  final String? avatar;

  UserModel({required this.id, required this.name, this.email, this.avatar});

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// DTO → Entity 转换
  UserEntity toEntity() {
    return UserEntity(id: id, name: name, email: email, avatar: avatar);
  }

  /// Entity → DTO 转换
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      avatar: entity.avatar,
    );
  }
}
