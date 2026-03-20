// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:booking_domain/booking_domain.dart';
import 'package:booking_data/booking_data.dart';
import 'package:common/common.dart';

/// Local data source with all possible continents.
class ContinentRepositoryLocal implements ContinentRepository {
  ContinentRepositoryLocal({required LocalDataService localDataService})
    : _localDataService = localDataService;

  final LocalDataService _localDataService;

  @override
  Future<Result<List<Continent>>> getContinents() async {
    return Future.value(Result.ok(_localDataService.getContinents()));
  }
}
