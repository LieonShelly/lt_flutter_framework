// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:booking_domain/booking_domain.dart';
import 'package:booking_data/booking_data.dart';
import 'package:common/common.dart';

/// Local implementation of DestinationRepository
/// Uses data from assets folder
class DestinationRepositoryLocal implements DestinationRepository {
  DestinationRepositoryLocal({required LocalDataService localDataService})
    : _localDataService = localDataService;

  final LocalDataService _localDataService;

  /// Obtain list of destinations from local assets
  @override
  Future<Result<List<Destination>>> getDestinations() async {
    try {
      return Result.ok(await _localDataService.getDestinations());
    } on Exception catch (error) {
      return Result.error(error);
    }
  }
}
