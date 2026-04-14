import 'package:mocktail/mocktail.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'package:test/test.dart';

// ─── Mock ────────────────────────────────────────────────────────────────────
class MockReflectionRepository extends Mock implements ReflectionRepository {}

void main() {
  late MockReflectionRepository mockRepository;
  late FetchAnswerDetailUseCase useCase;

  // ─── Fixtures ──────────────────────────────────────────────────────────────
  const tAnswerId = 'answer-123';
  final tAnswer = AnswerEntity(
    id: tAnswerId,
    content: '今天学到了很多新东西',
    createTms: DateTime(2025, 7, 10, 14, 30),
    createYmd: DateTime(2025, 7, 10),
  );

  setUp(() {
    mockRepository = MockReflectionRepository();
    useCase = FetchAnswerDetailUseCase(mockRepository);
  });

  group('FetchAnswerDetailUseCase', () {
    // ─── 正常路径 ──────────────────────────────────────────────────────────
    group('正常路径', () {
      test('应调用 repository.fetchAnswerDetail 并返回 AnswerEntity', () async {
        // arrange
        when(
          () => mockRepository.fetchAnswerDetail(tAnswerId),
        ).thenAnswer((_) async => tAnswer);

        // act
        final result = await useCase.execute(tAnswerId);

        // assert
        expect(result, equals(tAnswer));
        verify(() => mockRepository.fetchAnswerDetail(tAnswerId)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('应正确透传 answerId 参数给 repository', () async {
        const anotherId = 'answer-456';
        final anotherAnswer = AnswerEntity(
          id: anotherId,
          content: '另一条回答',
          createTms: DateTime(2025, 7, 11, 10, 0),
          createYmd: DateTime(2025, 7, 11),
        );

        when(
          () => mockRepository.fetchAnswerDetail(anotherId),
        ).thenAnswer((_) async => anotherAnswer);

        final result = await useCase.execute(anotherId);

        expect(result.id, equals(anotherId));
        expect(result.content, equals('另一条回答'));
        verify(() => mockRepository.fetchAnswerDetail(anotherId)).called(1);
      });

      test('应返回包含完整关联数据的 AnswerEntity（含 question 和 icon）', () async {
        final answerWithRelations = AnswerEntity(
          id: tAnswerId,
          content: '带关联数据的回答',
          createTms: DateTime(2025, 7, 10, 14, 30),
          createYmd: DateTime(2025, 7, 10),
          question: const QuestionEntity(
            id: 'q-1',
            title: '今天最开心的事是什么？',
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
          () => mockRepository.fetchAnswerDetail(tAnswerId),
        ).thenAnswer((_) async => answerWithRelations);

        final result = await useCase.execute(tAnswerId);

        expect(result.question, isNotNull);
        expect(result.question!.id, equals('q-1'));
        expect(result.icon, isNotNull);
        expect(result.icon!.url, equals('https://example.com/icon.png'));
      });

      test('应返回可选字段为 null 的 AnswerEntity（最小数据）', () async {
        const minimalAnswer = AnswerEntity(
          id: 'answer-minimal',
          content: '最简回答',
        );

        when(
          () => mockRepository.fetchAnswerDetail('answer-minimal'),
        ).thenAnswer((_) async => minimalAnswer);

        final result = await useCase.execute('answer-minimal');

        expect(result.id, equals('answer-minimal'));
        expect(result.createTms, isNull);
        expect(result.createYmd, isNull);
        expect(result.question, isNull);
        expect(result.icon, isNull);
      });
    });

    // ─── 异常分支 ──────────────────────────────────────────────────────────
    group('异常分支', () {
      test('repository 抛出 Exception 时应原样向上传播', () async {
        when(
          () => mockRepository.fetchAnswerDetail(tAnswerId),
        ).thenThrow(Exception('网络请求失败'));

        expect(
          () => useCase.execute(tAnswerId),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('网络请求失败'),
            ),
          ),
        );
        verify(() => mockRepository.fetchAnswerDetail(tAnswerId)).called(1);
      });

      test('repository 抛出 TypeError 时应原样向上传播', () async {
        when(
          () => mockRepository.fetchAnswerDetail(tAnswerId),
        ).thenThrow(TypeError());

        expect(() => useCase.execute(tAnswerId), throwsA(isA<TypeError>()));
      });

      test('repository 返回的 Future 以错误完成时应传播该错误', () async {
        when(
          () => mockRepository.fetchAnswerDetail(tAnswerId),
        ).thenAnswer((_) async => throw StateError('数据解析异常'));

        expect(
          () => useCase.execute(tAnswerId),
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
      test('answerId 为空字符串时应正常传递给 repository', () async {
        const emptyIdAnswer = AnswerEntity(id: '', content: '');

        when(
          () => mockRepository.fetchAnswerDetail(''),
        ).thenAnswer((_) async => emptyIdAnswer);

        final result = await useCase.execute('');

        expect(result.id, isEmpty);
        verify(() => mockRepository.fetchAnswerDetail('')).called(1);
      });

      test('answerId 包含特殊字符时应正常传递给 repository', () async {
        const specialId = 'answer/with spaces&special=chars';
        const specialAnswer = AnswerEntity(id: specialId, content: '特殊ID回答');

        when(
          () => mockRepository.fetchAnswerDetail(specialId),
        ).thenAnswer((_) async => specialAnswer);

        final result = await useCase.execute(specialId);

        expect(result.id, equals(specialId));
        verify(() => mockRepository.fetchAnswerDetail(specialId)).called(1);
      });

      test('content 为超长字符串时应正常返回', () async {
        final longContent = 'A' * 10000;
        final longAnswer = AnswerEntity(id: tAnswerId, content: longContent);

        when(
          () => mockRepository.fetchAnswerDetail(tAnswerId),
        ).thenAnswer((_) async => longAnswer);

        final result = await useCase.execute(tAnswerId);

        expect(result.content.length, equals(10000));
      });

      test('多次调用应每次都委托给 repository', () async {
        when(
          () => mockRepository.fetchAnswerDetail(tAnswerId),
        ).thenAnswer((_) async => tAnswer);

        await useCase.execute(tAnswerId);
        await useCase.execute(tAnswerId);
        await useCase.execute(tAnswerId);

        verify(() => mockRepository.fetchAnswerDetail(tAnswerId)).called(3);
      });
    });

    // ─── 接口契约 ──────────────────────────────────────────────────────────
    group('接口契约', () {
      test('UseCase 应实现 FetchAnswerDetailUseCaseType 接口', () {
        expect(useCase, isA<FetchAnswerDetailUseCaseType>());
      });
    });
  });
}
