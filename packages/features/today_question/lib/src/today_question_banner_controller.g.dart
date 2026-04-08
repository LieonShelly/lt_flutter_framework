// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_question_banner_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TodayQuestionBannerController)
final todayQuestionBannerControllerProvider =
    TodayQuestionBannerControllerProvider._();

final class TodayQuestionBannerControllerProvider
    extends
        $AsyncNotifierProvider<
          TodayQuestionBannerController,
          List<QuestionEntity>
        > {
  TodayQuestionBannerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayQuestionBannerControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayQuestionBannerControllerHash();

  @$internal
  @override
  TodayQuestionBannerController create() => TodayQuestionBannerController();
}

String _$todayQuestionBannerControllerHash() =>
    r'55c1bf51b1210626ae0d1017a848e2077ca8ff0b';

abstract class _$TodayQuestionBannerController
    extends $AsyncNotifier<List<QuestionEntity>> {
  FutureOr<List<QuestionEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<QuestionEntity>>, List<QuestionEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<QuestionEntity>>,
                List<QuestionEntity>
              >,
              AsyncValue<List<QuestionEntity>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
