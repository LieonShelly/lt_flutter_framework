import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet_data/wallet_data.dart';
import 'package:wallet_domain/wallet_domain.dart';

import 'kline_providers.dart';

class KlineState {
  final KlineKey key;
  final List<CandleEntity> candles;
  final bool isLoading;
  final bool isReconnecting;
  final Object? error;

  const KlineState({
    required this.key,
    this.candles = const [],
    this.isLoading = false,
    this.isReconnecting = false,
    this.error,
  });

  KlineState copyWith({
    KlineKey? key,
    List<CandleEntity>? candles,
    bool? isLoading,
    bool? isReconnecting,
    Object? error,
    bool clearError = false,
  }) {
    return KlineState(
      key: key ?? this.key,
      candles: candles ?? this.candles,
      isLoading: isLoading ?? this.isLoading,
      isReconnecting: isReconnecting ?? this.isReconnecting,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class KlineViewModel extends Notifier<KlineState> {
  late KlineRepository _repository;
  StreamSubscription<CandleEntity>? _realtimeSubscription;

  @override
  KlineState build() {
    _repository = ref.watch(klineRepositoryProvider);
    final key = ref.watch(defaultKlineKeyProvider);
    _subscribeRealtime(key);
    return KlineState(key: key);
  }

  void _subscribeRealtime(KlineKey key) {
    _realtimeSubscription?.cancel();
    _realtimeSubscription = _repository
        .watchRealtime(key)
        .listen(
          (incoming) {
            final candles = _mergeIncoming(state.candles, incoming);
            state = state.copyWith(candles: candles, clearError: true);
          },
          onError: (Object error) {
            state = state.copyWith(isReconnecting: true, error: error);
            _recoverAfterStreamError(key);
          },
        );
  }

  Future<void> loadInitial({int limit = 200}) async {
    final repository = ref.read(klineRepositoryProvider);
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final candles = await repository.getHistory(state.key, limit: limit);
      state = state.copyWith(candles: candles, isLoading: false);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error);
    }
  }

  Future<void> loadMoreBefore({int limit = 200}) async {
    if (state.candles.isEmpty) return;

    final repository = ref.read(klineRepositoryProvider);
    try {
      final candles = await repository.loadMoreBefore(
        state.key,
        state.candles.first.openTime,
        limit: limit,
      );
      state = state.copyWith(candles: candles, clearError: true);
    } catch (error) {
      state = state.copyWith(error: error);
    }
  }

  Future<void> switchKey(KlineKey key) async {
    _realtimeSubscription?.cancel();
    state = KlineState(key: key, isLoading: true);
    _subscribeRealtime(key);
    await loadInitial();
  }

  Future<void> _recoverAfterStreamError(KlineKey key) async {
    if (state.candles.isEmpty) {
      await loadInitial();
      return;
    }

    final repository = ref.read(klineRepositoryProvider);
    try {
      final candles = await repository.recoverFrom(
        key,
        state.candles.last.openTime,
      );
      state = state.copyWith(
        candles: candles,
        isReconnecting: false,
        clearError: true,
      );
      _subscribeRealtime(key);
    } catch (error) {
      state = state.copyWith(isReconnecting: false, error: error);
    }
  }

  List<CandleEntity> _mergeIncoming(
    List<CandleEntity> source,
    CandleEntity incoming,
  ) {
    final candles = List<CandleEntity>.from(source);
    if (candles.isEmpty) {
      return [incoming];
    }

    final last = candles.last;
    if (incoming.openTime == last.openTime) {
      candles[candles.length - 1] = incoming;
      return List.unmodifiable(candles);
    }

    if (incoming.openTime > last.openTime) {
      candles.add(incoming);
      return List.unmodifiable(candles);
    }

    final index = candles.indexWhere(
      (candle) => candle.openTime == incoming.openTime,
    );
    if (index >= 0) {
      candles[index] = incoming;
    }
    return List.unmodifiable(candles);
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
  }
}
