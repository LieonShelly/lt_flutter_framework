// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:booking_domain/booking_domain.dart';
import 'package:common/common.dart';

/// In-memory implementation of [ItineraryConfigRepository].
class ItineraryConfigRepositoryMemory implements ItineraryConfigRepository {
  ItineraryConfig? _itineraryConfig;

  @override
  Future<Result<ItineraryConfig>> getItineraryConfig() async {
    return Result.ok(_itineraryConfig ?? const ItineraryConfig());
  }

  @override
  Future<Result<bool>> setItineraryConfig(
    ItineraryConfig itineraryConfig,
  ) async {
    _itineraryConfig = itineraryConfig;
    return const Result.ok(true);
  }
}
