import 'package:mocktail/mocktail.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'package:test/test.dart';

// ─── Mock ────────────────────────────────────────────────────────────────────
class MockReflectionRepository extends Mock implements ReflectionRepository {}

void main() {
  late MockReflectionRepository mockRepository;
  late FetchThreadQuestionsUseCase useCase;

  // ─── Fixtures ──────────────────────────────────────────────────────────────
  const tCategory = CategoryEntity(id: 'cat-1', name: '日常');

  const tPinnedQuestion = QuestionEntity(
    id: 'q-1',
    title: '置顶问题',
    category: tCategory,
    pinned: true,
    answers: [],
  );

  const tUnpinnedQuestion1 = QuestionEntity(
    id: 'q-2',
    title: '普通问题1',
    category: tCategory,
    pinned: false,
    answers: [],
  );

  const tUnpinnedQuestion2 = QuestionEntity(
    id: 'q-3',
    title: '普通问题2',
    category: tCategory,
    pinned: false,
    answers: [],
  );

  setUp(() {
    mockRepository = MockReflectionRepository();
    useCase = FetchThreadQuestionsUseCase(mockRepository);
  });

  group('FetchThreadQuestionsUseCase', () {
    // ─── 正常路径 ──────────────────────────────────────────────────────────
    group('正常路径', () {
      test('应调用 repository.fetchThreadQuestions 并返回结果', () async {
        when(
          () => mockRepository.fetchThreadQuestions(),
        ).thenAnswer((_) async => [tUnpinnedQuestion1]);

        final result = await useCase.execute();

        expect(result, equals([tUnpinnedQuestion1]));
        verify(() => mockRepository.fetchThreadQuestions()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('应返回 List<QuestionEntity> 类型的结果', () async {
        when(
          () => mockRepository.fetchThreadQuestions(),
        ).thenAnswer((_) async => []);

        final result = await useCase.execute();

        expect(result, isA<List<QuestionEntity>>());
      });
    });

    // ─── 业务逻辑 — 排序 ──────────────────────────────────────────────────
    group('业务逻辑 — 排序', () {
      test('应将 pinned 问题排在前面', () async {
        when(() => mockRepository.fetchThreadQuestions()).thenAnswer(
          (_) async => [
            tUnpinnedQuestion1,
            tPinnedQuestion,
            tUnpinnedQuestion2,
          ],
        );

        final result = await useCase.execute();

        expect(result.first.id, equals('q-1'));
        expect(result.first.pinned, isTrue);
      });

      test('pinned 问题已在前面时应保持顺序不变', () async {
        when(() => mockRepository.fetchThreadQuestions()).thenAnswer(
          (_) async => [
            tPinnedQuestion,
            tUnpinnedQuestion1,
            tUnpinnedQuestion2,
          ],
        );

        final result = await useCase.execute();

        expect(result[0].id, equals('q-1'));
        expect(result[1].id, equals('q-2'));
        expect(result[2].id, equals('q-3'));
      });

      test('多个 pinned 问题应都排在 unpinned 前面', () async {
        const tPinnedQuestion2 = QuestionEntity(
          id: 'q-4',
          title: '置顶问题2',
          category: tCategory,
          pinned: true,
          answers: [],
        );

        when(() => mockRepository.fetchThreadQuestions()).thenAnswer(
          (_) async => [
            tUnpinnedQuestion1,
            tPinnedQuestion2,
            tUnpinnedQuestion2,
            tPinnedQuestion,
          ],
        );

        final result = await useCase.execute();

        expect(result[0].pinned, isTrue);
        expect(result[1].pinned, isTrue);
        expect(result[2].pinned, isFalse);
        expect(result[3].pinned, isFalse);
      });

      test('所有问题都是 pinned 时应保持原始相对顺序', () async {
        const p1 = QuestionEntity(
          id: 'p-1',
          title: '置顶A',
          category: tCategory,
          pinned: true,
          answers: [],
        );
        const p2 = QuestionEntity(
          id: 'p-2',
          title: '置顶B',
          category: tCategory,
          pinned: true,
          answers: [],
        );

        when(
          () => mockRepository.fetchThreadQuestions(),
        ).thenAnswer((_) async => [p1, p2]);

        final result = await useCase.execute();

        expect(result.length, equals(2));
        expect(result.every((q) => q.pinned), isTrue);
      });

      test('所有问题都是 unpinned 时应保持原始相对顺序', () async {
        when(
          () => mockRepository.fetchThreadQuestions(),
        ).thenAnswer((_) async => [tUnpinnedQuestion2, tUnpinnedQuestion1]);

        final result = await useCase.execute();

        expect(result[0].id, equals('q-3'));
        expect(result[1].id, equals('q-2'));
      });
    });

    // ─── 异常分支 ──────────────────────────────────────────────────────────
    group('异常分支', () {
      test('repository 抛出 Exception 时应原样向上传播', () async {
        when(
          () => mockRepository.fetchThreadQuestions(),
        ).thenThrow(Exception('网络请求失败'));

        expect(
          () => useCase.execute(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('网络请求失败'),
            ),
          ),
        );
        verify(() => mockRepository.fetchThreadQuestions()).called(1);
      });

      test('repository 抛出 TypeError 时应原样向上传播', () async {
        when(
          () => mockRepository.fetchThreadQuestions(),
        ).thenThrow(TypeError());

        expect(() => useCase.execute(), throwsA(isA<TypeError>()));
      });

      test('repository 返回的 Future 以错误完成时应传播该错误', () async {
        when(
          () => mockRepository.fetchThreadQuestions(),
        ).thenAnswer((_) async => throw StateError('数据解析异常'));

        expect(
          () => useCase.execute(),
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
      test('repository 返回空列表时应返回空列表', () async {
        when(
          () => mockRepository.fetchThreadQuestions(),
        ).thenAnswer((_) async => []);

        final result = await useCase.execute();

        expect(result, isEmpty);
      });

      test('repository 返回单个元素时应正常返回', () async {
        when(
          () => mockRepository.fetchThreadQuestions(),
        ).thenAnswer((_) async => [tPinnedQuestion]);

        final result = await useCase.execute();

        expect(result.length, equals(1));
        expect(result.first, equals(tPinnedQuestion));
      });

      test('多次调用应每次都委托给 repository', () async {
        when(
          () => mockRepository.fetchThreadQuestions(),
        ).thenAnswer((_) async => []);

        await useCase.execute();
        await useCase.execute();
        await useCase.execute();

        verify(() => mockRepository.fetchThreadQuestions()).called(3);
      });
    });

    // ─── 接口契约 ──────────────────────────────────────────────────────────
    group('接口契约', () {
      test('UseCase 应实现 FetchThreadQuestionsUseCaseType 接口', () {
        expect(useCase, isA<FetchThreadQuestionsUseCaseType>());
      });
    });
  });
}
