import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:wallet_domain/wallet_domain.dart';

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

class KlineViewModel extends ChangeNotifier {
  final KlineRepository _repository;

  KlineState _state;
  StreamSubscription<CandleEntity>? _realtimeSubscription;

  KlineViewModel({
    required KlineRepository repository,
    required KlineKey initialKey,
  }) : _repository = repository,
       _state = KlineState(key: initialKey);

  KlineState get state => _state;

  Future<void> loadInitial({int limit = 200}) async {
    _emit(_state.copyWith(isLoading: true, clearError: true));

    try {
      final candles = await _repository.getHistory(_state.key, limit: limit);
      _emit(_state.copyWith(candles: candles, isLoading: false));
      _subscribeRealtime();
    } catch (error) {
      _emit(_state.copyWith(isLoading: false, error: error));
    }
  }

  Future<void> loadMoreBefore({int limit = 200}) async {
    if (_state.candles.isEmpty) {
      return;
    }

    try {
      final candles = await _repository.loadMoreBefore(
        _state.key,
        _state.candles.first.openTime,
        limit: limit,
      );
      _emit(_state.copyWith(candles: candles, clearError: true));
    } catch (error) {
      _emit(_state.copyWith(error: error));
    }
  }

  Future<void> switchKey(KlineKey key) async {
    await _realtimeSubscription?.cancel();
    _state = KlineState(key: key, isLoading: true);
    notifyListeners();
    await loadInitial();
  }

  void _subscribeRealtime() {
    _realtimeSubscription?.cancel();
    _realtimeSubscription = _repository
        .watchRealtime(_state.key)
        .listen(
          (incoming) {
            final candles = _mergeIncoming(_state.candles, incoming);
            _emit(_state.copyWith(candles: candles, clearError: true));
          },
          onError: (Object error) {
            _emit(_state.copyWith(isReconnecting: true, error: error));
            _recoverAfterStreamError();
          },
        );
  }

  Future<void> _recoverAfterStreamError() async {
    if (_state.candles.isEmpty) {
      await loadInitial();
      return;
    }

    try {
      final candles = await _repository.recoverFrom(
        _state.key,
        _state.candles.last.openTime,
      );
      _emit(
        _state.copyWith(
          candles: candles,
          isReconnecting: false,
          clearError: true,
        ),
      );
      _subscribeRealtime();
    } catch (error) {
      _emit(_state.copyWith(isReconnecting: false, error: error));
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

  void _emit(KlineState state) {
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }
}
