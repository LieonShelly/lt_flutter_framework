// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CalendarViewModel)
final calendarViewModelProvider = CalendarViewModelProvider._();

final class CalendarViewModelProvider
    extends $NotifierProvider<CalendarViewModel, CalendarState> {
  CalendarViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarViewModelHash();

  @$internal
  @override
  CalendarViewModel create() => CalendarViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalendarState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalendarState>(value),
    );
  }
}

String _$calendarViewModelHash() => r'79f9da9275b26d10d152de369f98da744b86e2b0';

abstract class _$CalendarViewModel extends $Notifier<CalendarState> {
  CalendarState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CalendarState, CalendarState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CalendarState, CalendarState>,
              CalendarState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
