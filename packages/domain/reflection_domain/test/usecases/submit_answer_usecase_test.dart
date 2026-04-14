import 'package:mocktail/mocktail.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'package:test/test.dart';

// ─── Mock ────────────────────────────────────────────────────────────────────
class MockReflectionRepository extends Mock implements ReflectionRepository {}

void main() {
  late MockReflectionRepository mockRepository;
  late SubmitAnswerUseCase useCase;

  // ─── Fixtures ──────────────────────────────────────────────────────────────
  const tQuestionId = 'q-123';
  const tContent = '今天学到了很多新东西';
  const tIconId = 'icon-1';

  final tAnswer = AnswerEntity(
    id: 'a-1',
    content: tContent,
    createTms: DateTime(2025, 7, 10, 14, 30),
    createYmd: DateTime(2025, 7, 10),
  );

  setUp(() {
    mockRepository = MockReflectionRepository();
    useCase = SubmitAnswerUseCase(mockRepository);
  });

  group('SubmitAnswerUseCase', () {
    // ─── 正常路径 ──────────────────────────────────────────────────────────
    group('正常路径', () {
      test('应调用 repository.submitAnswer 并返回 AnswerEntity', () async {
        when(
          () => mockRepository.submitAnswer(
            questionId: tQuestionId,
            content: tContent,
            iconId: null,
          ),
        ).thenAnswer((_) async => tAnswer);

        final result = await useCase.execute(
          questionId: tQuestionId,
          content: tContent,
        );

        expect(result, equals(tAnswer));
        verify(
          () => mockRepository.submitAnswer(
            questionId: tQuestionId,
            content: tContent,
            iconId: null,
          ),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('应正确透传所有参数（含 iconId）给 repository', () async {
        when(
          () => mockRepository.submitAnswer(
            questionId: tQuestionId,
            content: tContent,
            iconId: tIconId,
          ),
        ).thenAnswer((_) async => tAnswer);

        final result = await useCase.execute(
          questionId: tQuestionId,
          content: tContent,
          iconId: tIconId,
        );

        expect(result, equals(tAnswer));
        verify(
          () => mockRepository.submitAnswer(
            questionId: tQuestionId,
            content: tContent,
            iconId: tIconId,
          ),
        ).called(1);
      });

      test('应返回包含完整关联数据的 AnswerEntity', () async {
        final answerWithRelations = AnswerEntity(
          id: 'a-2',
          content: tContent,
          createTms: DateTime(2025, 7, 10, 14, 30),
          createYmd: DateTime(2025, 7, 10),
          question: const QuestionEntity(
            id: tQuestionId,
            title: '今天最开心的事？',
            category: CategoryEntity(id: 'cat-1', name: '日常'),
            pinned: false,
            answers: [],
          ),
          icon: const IconEntity(
            status: IconStatus.generated,
            url: 'https://example.com/icon.png',
          ),
        );

        when(
          () => mockRepository.submitAnswer(
            questionId: tQuestionId,
            content: tContent,
            iconId: null,
          ),
        ).thenAnswer((_) async => answerWithRelations);

        final result = await useCase.execute(
          questionId: tQuestionId,
          content: tContent,
        );

        expect(result.question, isNotNull);
        expect(result.icon, isNotNull);
      });
    });

    // ─── 业务逻辑 — 输入验证 ──────────────────────────────────────────────
    group('业务逻辑 — 输入验证', () {
      test('content 为空字符串时应抛出 ArgumentError', () async {
        expect(
          () => useCase.execute(questionId: tQuestionId, content: ''),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              equals('答案内容不能为空'),
            ),
          ),
        );
        verifyNever(
          () => mockRepository.submitAnswer(
            questionId: any(named: 'questionId'),
            content: any(named: 'content'),
            iconId: any(named: 'iconId'),
          ),
        );
      });

      test('content 仅包含空白字符时应抛出 ArgumentError', () async {
        expect(
          () => useCase.execute(questionId: tQuestionId, content: '   \t\n  '),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              equals('答案内容不能为空'),
            ),
          ),
        );
        verifyNever(
          () => mockRepository.submitAnswer(
            questionId: any(named: 'questionId'),
            content: any(named: 'content'),
            iconId: any(named: 'iconId'),
          ),
        );
      });

      test('content 超过 1000 字时应抛出 ArgumentError', () async {
        final longContent = 'A' * 1001;

        expect(
          () => useCase.execute(questionId: tQuestionId, content: longContent),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              equals('答案内容不能超过 1000 字'),
            ),
          ),
        );
        verifyNever(
          () => mockRepository.submitAnswer(
            questionId: any(named: 'questionId'),
            content: any(named: 'content'),
            iconId: any(named: 'iconId'),
          ),
        );
      });

      test('content 恰好 1000 字时应正常提交', () async {
        final exactContent = 'A' * 1000;

        when(
          () => mockRepository.submitAnswer(
            questionId: tQuestionId,
            content: exactContent,
            iconId: null,
          ),
        ).thenAnswer(
          (_) async => AnswerEntity(id: 'a-3', content: exactContent),
        );

        final result = await useCase.execute(
          questionId: tQuestionId,
          content: exactContent,
        );

        expect(result.content.length, equals(1000));
        verify(
          () => mockRepository.submitAnswer(
            questionId: tQuestionId,
            content: exactContent,
            iconId: null,
          ),
        ).called(1);
      });

      test('content 恰好 1 个字符时应正常提交', () async {
        when(
          () => mockRepository.submitAnswer(
            questionId: tQuestionId,
            content: 'A',
            iconId: null,
          ),
        ).thenAnswer((_) async => const AnswerEntity(id: 'a-4', content: 'A'));

        final result = await useCase.execute(
          questionId: tQuestionId,
          content: 'A',
        );

        expect(result.content, equals('A'));
      });

      test('验证失败时不应调用 repository', () async {
        try {
          await useCase.execute(questionId: tQuestionId, content: '');
        } catch (_) {}

        try {
          await useCase.execute(questionId: tQuestionId, content: 'A' * 1001);
        } catch (_) {}

        verifyNever(
          () => mockRepository.submitAnswer(
            questionId: any(named: 'questionId'),
            content: any(named: 'content'),
            iconId: any(named: 'iconId'),
          ),
        );
      });
    });

    // ─── 异常分支 ──────────────────────────────────────────────────────────
    group('异常分支', () {
      test('repository 抛出 Exception 时应原样向上传播', () async {
        when(
          () => mockRepository.submitAnswer(
            questionId: tQuestionId,
            content: tContent,
            iconId: null,
          ),
        ).thenThrow(Exception('网络请求失败'));

        expect(
          () => useCase.execute(questionId: tQuestionId, content: tContent),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('网络请求失败'),
            ),
          ),
        );
      });

      test('repository 抛出 TypeError 时应原样向上传播', () async {
        when(
          () => mockRepository.submitAnswer(
            questionId: tQuestionId,
            content: tContent,
            iconId: null,
          ),
        ).thenThrow(TypeError());

        expect(
          () => useCase.execute(questionId: tQuestionId, content: tContent),
          throwsA(isA<TypeError>()),
        );
      });

      test('repository 返回的 Future 以错误完成时应传播该错误', () async {
        when(
          () => mockRepository.submitAnswer(
            questionId: tQuestionId,
            content: tContent,
            iconId: null,
          ),
        ).thenAnswer((_) async => throw StateError('数据解析异常'));

        expect(
          () => useCase.execute(questionId: tQuestionId, content: tContent),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              equals('数据解析异常'),
            ),
          ),
        );
      });
    });

    // ─── 边界条件 ──────────────────────────────────────────────────────────
    group('边界条件', () {
      test('iconId 为 null 时应正常传递给 repository', () async {
        when(
          () => mockRepository.submitAnswer(
            questionId: tQuestionId,
            content: tContent,
            iconId: null,
          ),
        ).thenAnswer((_) async => tAnswer);

        await useCase.execute(questionId: tQuestionId, content: tContent);

        verify(
          () => mockRepository.submitAnswer(
            questionId: tQuestionId,
            content: tContent,
            iconId: null,
          ),
        ).called(1);
      });

      test('iconId 有值时应正常传递给 repository', () async {
        when(
          () => mockRepository.submitAnswer(
            questionId: tQuestionId,
            content: tContent,
            iconId: tIconId,
          ),
        ).thenAnswer((_) async => tAnswer);

        await useCase.execute(
          questionId: tQuestionId,
          content: tContent,
          iconId: tIconId,
        );

        verify(
          () => mockRepository.submitAnswer(
            questionId: tQuestionId,
            content: tContent,
            iconId: tIconId,
          ),
        ).called(1);
      });

      test('questionId 包含特殊字符时应正常传递', () async {
        const specialId = 'q/with spaces&special=chars';

        when(
          () => mockRepository.submitAnswer(
            questionId: specialId,
            content: tContent,
            iconId: null,
          ),
        ).thenAnswer((_) async => tAnswer);

        await useCase.execute(questionId: specialId, content: tContent);

        verify(
          () => mockRepository.submitAnswer(
            questionId: specialId,
            content: tContent,
            iconId: null,
          ),
        ).called(1);
      });

      test('多次调用应每次都委托给 repository', () async {
        when(
          () => mockRepository.submitAnswer(
            questionId: any(named: 'questionId'),
            content: any(named: 'content'),
            iconId: any(named: 'iconId'),
          ),
        ).thenAnswer((_) async => tAnswer);

        await useCase.execute(questionId: tQuestionId, content: tContent);
        await useCase.execute(questionId: tQuestionId, content: tContent);

        verify(
          () => mockRepository.submitAnswer(
            questionId: any(named: 'questionId'),
            content: any(named: 'content'),
            iconId: any(named: 'iconId'),
          ),
        ).called(2);
      });
    });

    // ─── 接口契约 ──────────────────────────────────────────────────────────
    group('接口契约', () {
      test('UseCase 应实现 SubmitAnswerUseCaseType 接口', () {
        expect(useCase, isA<SubmitAnswerUseCaseType>());
      });
    });
  });
}
