// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_model.dart';

// **************************************************************************
// LtDeserializationGenerator
// **************************************************************************

AuthModel _$AuthModelFromJson(Map<String, dynamic> json) {
  return AuthModel(
    accessToken: json['access_token'] as String,
    refreshToken: json['refresh_token'] as String,
    user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
  );
}
