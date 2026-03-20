import 'dart:convert';

import 'package:booking_domain/booking_domain.dart';
import 'package:common/common.dart';
import 'package:lt_network/network.dart';
import '../../model/model.dart';

class RemoteDatasource {
  final ApiClientType _apiClient;
  const RemoteDatasource({required ApiClientType apiClient})
    : _apiClient = apiClient;

  Future<Result<List<Continent>>> getContinents() async {
    try {
      final response = await _apiClient.get('/continet');
      if (response is List) {
        return Result.ok(
          response.map((element) => Continent.fromJson(element)).toList(),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
    return Result.error(AppException(message: "Invlild response"));
  }

  Future<Result<List<Destination>>> getDestination() async {
    try {
      final response = await _apiClient.get('/destination');
      if (response is List) {
        return Result.ok(
          response.map((element) => Destination.fromJson(element)).toList(),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
    return Result.error(AppException(message: "Invlild response"));
  }

  Future<Result<List<Activity>>> getActivityByDestination(String ref) async {
    try {
      final response = await _apiClient.get('/destination/$ref/activity');
      if (response is List) {
        return Result.ok(
          response.map((element) => Activity.fromJson(element)).toList(),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
    return Result.error(AppException(message: "Invlild response"));
  }

  Future<Result<List<Destination>>> getDestinations() async {
    try {
      final response = await _apiClient.get('/destination');
      if (response is List) {
        return Result.ok(
          response.map((element) => Destination.fromJson(element)).toList(),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
    return Result.error(AppException(message: "Invalid response"));
  }

  Future<Result<List<BookingApiModel>>> getBookings() async {
    try {
      final response = await _apiClient.get('/booking');
      if (response is List) {
        return Result.ok(
          response.map((element) => BookingApiModel.fromJson(element)).toList(),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
    return Result.error(AppException(message: "Invalid response"));
  }

  Future<Result<BookingApiModel>> getBooking(int id) async {
    try {
      final response = await _apiClient.get('/booking/$id');
      if (response is Map<String, dynamic>) {
        return Result.ok(BookingApiModel.fromJson(response));
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
    return Result.error(AppException(message: "Invalid response"));
  }

  Future<Result<BookingApiModel>> postBooking(BookingApiModel booking) async {
    try {
      final response = await _apiClient.post(
        '/booking',
        data: jsonEncode(booking),
      );
      if (response is Map<String, dynamic>) {
        return Result.ok(BookingApiModel.fromJson(response));
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
    return Result.error(AppException(message: "Invalid response"));
  }

  Future<Result<UserApiModel>> getUser() async {
    try {
      final response = await _apiClient.get('/user');
      if (response is Map<String, dynamic>) {
        return Result.ok(UserApiModel.fromJson(response));
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
    return Result.error(AppException(message: "Invalid response"));
  }

  Future<Result<void>> deleteBooking(int id) async {
    try {
      final _ = await _apiClient.delete('/booking/$id');
      return const Result.ok(null);
    } on Exception catch (error) {
      return Result.error(error);
    }
  }
}
