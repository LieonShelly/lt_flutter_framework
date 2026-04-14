import 'package:mocktail/mocktail.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'package:test/test.dart';

// ─── Mock ────────────────────────────────────────────────────────────────────
class MockReflectionRepository extends Mock implements ReflectionRepository {}

void main() {
  late MockReflectionRepository mockRepository;
  late FetchTodayQuestionUseCase useCase;

  // ─── Fixtures ──────────────────────────────────────────────────────────────
  const tCategory = CategoryEntity(id: 'cat-1', name: '日常');

  const tQuestion1 = QuestionEntity(
    id: 'q-1',
    title: '今天最开心的事是什么？',
    category: tCategory,
    pinned: false,
    answers: [],
  );

  const tQuestion2 = QuestionEntity(
    id: 'q-2',
    title: '今天学到了什么？',
    category: tCategory,
    pinned: false,
    answers: [],
  );

  setUp(() {
    mockRepository = MockReflectionRepository();
    useCase = FetchTodayQuestionUseCase(mockRepository);
  });

  group('FetchTodayQuestionUseCase', () {
    // ─── 正常路径 ──────────────────────────────────────────────────────────
    group('正常路径', () {
      test('应调用 repository.fetchTodayQuestions 并返回结果', () async {
        when(
          () => mockRepository.fetchTodayQuestions(),
        ).thenAnswer((_) async => [tQuestion1]);

        final result = await useCase.execute();

        expect(result, equals([tQuestion1]));
        verify(() => mockRepository.fetchTodayQuestions()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('应返回 List<QuestionEntity> 类型的结果', () async {
        when(
          () => mockRepository.fetchTodayQuestions(),
        ).thenAnswer((_) async => [tQuestion1, tQuestion2]);

        final result = await useCase.execute();

        expect(result, isA<List<QuestionEntity>>());
        expect(result.length, equals(2));
      });

      test('应返回包含完整关联数据的 QuestionEntity', () async {
        const questionWithSub = QuestionEntity(
          id: 'q-3',
          title: '带子分类的问题',
          category: tCategory,
          pinned: true,
          subCategory: CategoryEntity(id: 'sub-1', name: '子分类'),
          answers: [AnswerEntity(id: 'a-1', content: '回答内容')],
        );

        when(
          () => mockRepository.fetchTodayQuestions(),
        ).thenAnswer((_) async => [questionWithSub]);

        final result = await useCase.execute();

        expect(result.first.subCategory, isNotNull);
        expect(result.first.subCategory!.name, equals('子分类'));
        expect(result.first.answers.length, equals(1));
      });
    });

    // ─── 异常分支 ──────────────────────────────────────────────────────────
    group('异常分支', () {
      test('repository 抛出 Exception 时应原样向上传播', () async {
        when(
          () => mockRepository.fetchTodayQuestions(),
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
        verify(() => mockRepository.fetchTodayQuestions()).called(1);
      });

      test('repository 抛出 TypeError 时应原样向上传播', () async {
        when(() => mockRepository.fetchTodayQuestions()).thenThrow(TypeError());

        expect(() => useCase.execute(), throwsA(isA<TypeError>()));
      });

      test('repository 返回的 Future 以错误完成时应传播该错误', () async {
        when(
          () => mockRepository.fetchTodayQuestions(),
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
          () => mockRepository.fetchTodayQuestions(),
        ).thenAnswer((_) async => []);

        final result = await useCase.execute();

        expect(result, isEmpty);
      });

      test('repository 返回单个元素时应正常返回', () async {
        when(
          () => mockRepository.fetchTodayQuestions(),
        ).thenAnswer((_) async => [tQuestion1]);

        final result = await useCase.execute();

        expect(result.length, equals(1));
        expect(result.first.id, equals('q-1'));
      });

      test('多次调用应每次都委托给 repository', () async {
        when(
          () => mockRepository.fetchTodayQuestions(),
        ).thenAnswer((_) async => []);

        await useCase.execute();
        await useCase.execute();
        await useCase.execute();

        verify(() => mockRepository.fetchTodayQuestions()).called(3);
      });
    });

    // ─── 接口契约 ──────────────────────────────────────────────────────────
    group('接口契约', () {
      test('UseCase 应实现 FetchTodayQuestionUseCaseType 接口', () {
        expect(useCase, isA<FetchTodayQuestionUseCaseType>());
      });
    });
  });
}
