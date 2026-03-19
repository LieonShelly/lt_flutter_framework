import 'package:lt_annotation/annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reflection_domain/reflection_domain.dart';

part 'icon_model.lt_model.dart';
part 'icon_model.freezed.dart';

@freezed
@ltDeserialization
class IconModel with _$IconModel {
  final String? url;
  final String status;

  IconModel({this.url, this.status = "unknown"});

  factory IconModel.fromJson(Map<String, dynamic> json) =>
      _$IconModelFromJson(json);

  IconEntity toEntity() {
    return IconEntity(status: IconStatus.fromString(status), url: url ?? "");
  }

  factory IconModel.fromEntity(IconEntity entity) {
    return IconModel(url: entity.url, status: IconStatus.generated.toString());
  }
}
