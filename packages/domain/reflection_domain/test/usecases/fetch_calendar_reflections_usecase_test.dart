import 'package:mocktail/mocktail.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'package:test/test.dart';

// ─── Mock ────────────────────────────────────────────────────────────────────
class MockReflectionRepository extends Mock implements ReflectionRepository {}

void main() {
  late MockReflectionRepository mockRepository;
  late CalendarFetchReflectionUseCase useCase;

  // ─── Fixtures ──────────────────────────────────────────────────────────────
  final tStart = DateTime(2025, 7, 1);
  final tEnd = DateTime(2025, 7, 31);

  const tAnswer1 = AnswerEntity(id: 'a-1', content: '回答1');
  const tAnswer2 = AnswerEntity(id: 'a-2', content: '回答2');

  final tCalendarDays = [
    const CalendarDayEntity(date: '2025-07-05', answers: [tAnswer1]),
    const CalendarDayEntity(date: '2025-07-08', answers: [tAnswer2]),
  ];

  setUp(() {
    mockRepository = MockReflectionRepository();
    useCase = CalendarFetchReflectionUseCase(repository: mockRepository);
  });

  group('CalendarFetchReflectionUseCase', () {
    // ─── 正常路径 ──────────────────────────────────────────────────────────
    group('正常路径', () {
      test('应调用 repository.fetchCalendarView 并传递正确的 start/end 参数', () async {
        when(
          () => mockRepository.fetchCalendarView(start: tStart, end: tEnd),
        ).thenAnswer((_) async => tCalendarDays);

        await useCase.execute(tStart, tEnd);

        verify(
          () => mockRepository.fetchCalendarView(start: tStart, end: tEnd),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test('应返回 Map<String, CalendarDayItem> 类型的结果', () async {
        when(
          () => mockRepository.fetchCalendarView(start: tStart, end: tEnd),
        ).thenAnswer((_) async => tCalendarDays);

        final result = await useCase.execute(tStart, tEnd);

        expect(result, isA<Map<String, CalendarDayItem>>());
      });
    });

    // ─── 业务逻辑 — 空列表分支 ────────────────────────────────────────────
    group('业务逻辑 — 空列表分支', () {
      test('repository 返回空列表时，应用 start 到 end 填充日期', () async {
        final start = DateTime(2025, 7, 1);
        final end = DateTime(2025, 7, 3);

        when(
          () => mockRepository.fetchCalendarView(start: start, end: end),
        ).thenAnswer((_) async => []);

        final result = await useCase.execute(start, end);

        expect(result.length, equals(3));
        expect(result.containsKey('2025-07-01'), isTrue);
        expect(result.containsKey('2025-07-02'), isTrue);
        expect(result.containsKey('2025-07-03'), isTrue);
      });

      test('空列表时，每天的 style 应为 CalendarDayOnlyDateStyle', () async {
        final start = DateTime(2025, 7, 1);
        final end = DateTime(2025, 7, 2);

        when(
          () => mockRepository.fetchCalendarView(start: start, end: end),
        ).thenAnswer((_) async => []);

        final result = await useCase.execute(start, end);

        for (final item in result.values) {
          expect(item.style, isA<CalendarDayOnlyDateStyle>());
        }
      });

      test('空列表且 start == end 时，应只返回一天', () async {
        final sameDay = DateTime(2025, 7, 15);

        when(
          () => mockRepository.fetchCalendarView(start: sameDay, end: sameDay),
        ).thenAnswer((_) async => []);

        final result = await useCase.execute(sameDay, sameDay);

        expect(result.length, equals(1));
        expect(result.containsKey('2025-07-15'), isTrue);
      });
    });

    // ─── 业务逻辑 — 非空列表分支 ──────────────────────────────────────────
    group('业务逻辑 — 非空列表分支', () {
      test('非空列表时，应用 list.first.date 到 list.last.date 的范围填充', () async {
        final days = [
          const CalendarDayEntity(date: '2025-07-03', answers: [tAnswer1]),
          const CalendarDayEntity(date: '2025-07-06', answers: [tAnswer2]),
        ];

        when(
          () => mockRepository.fetchCalendarView(start: tStart, end: tEnd),
        ).thenAnswer((_) async => days);

        final result = await useCase.execute(tStart, tEnd);

        // 从 07-03 到 07-06 共 4 天
        expect(result.length, equals(4));
        expect(result.containsKey('2025-07-03'), isTrue);
        expect(result.containsKey('2025-07-04'), isTrue);
        expect(result.containsKey('2025-07-05'), isTrue);
        expect(result.containsKey('2025-07-06'), isTrue);
      });

      test('无数据的日期 style 应为 CalendarDayDashlineStyle', () async {
        final days = [
          const CalendarDayEntity(date: '2025-07-10', answers: [tAnswer1]),
          const CalendarDayEntity(date: '2025-07-12', answers: [tAnswer2]),
        ];

        when(
          () => mockRepository.fetchCalendarView(start: tStart, end: tEnd),
        ).thenAnswer((_) async => days);

        final result = await useCase.execute(tStart, tEnd);

        // 07-11 没有数据，应为 DashlineStyle
        expect(result['2025-07-11']!.style, isA<CalendarDayDashlineStyle>());
      });

      test('有数据的日期 style 应为 CalendarReflectionsStyle 并包含正确的 answers', () async {
        final days = [
          const CalendarDayEntity(
            date: '2025-07-10',
            answers: [tAnswer1, tAnswer2],
          ),
        ];

        when(
          () => mockRepository.fetchCalendarView(start: tStart, end: tEnd),
        ).thenAnswer((_) async => days);

        final result = await useCase.execute(tStart, tEnd);

        final style = result['2025-07-10']!.style;
        expect(style, isA<CalendarReflectionsStyle>());
        final reflectionsStyle = style as CalendarReflectionsStyle;
        expect(reflectionsStyle.date, equals('2025-07-10'));
        expect(reflectionsStyle.reflections.length, equals(2));
        expect(reflectionsStyle.reflections[0].id, equals('a-1'));
        expect(reflectionsStyle.reflections[1].id, equals('a-2'));
      });

      test(
        'CalendarReflectionsStyle 应覆盖先前填充的 CalendarDayDashlineStyle',
        () async {
          final days = [
            const CalendarDayEntity(date: '2025-07-01', answers: [tAnswer1]),
            const CalendarDayEntity(date: '2025-07-03', answers: [tAnswer2]),
          ];

          when(
            () => mockRepository.fetchCalendarView(start: tStart, end: tEnd),
          ).thenAnswer((_) async => days);

          final result = await useCase.execute(tStart, tEnd);

          // 07-01 和 07-03 有数据，应被覆盖为 ReflectionsStyle
          expect(result['2025-07-01']!.style, isA<CalendarReflectionsStyle>());
          expect(result['2025-07-03']!.style, isA<CalendarReflectionsStyle>());
          // 07-02 无数据，保持 DashlineStyle
          expect(result['2025-07-02']!.style, isA<CalendarDayDashlineStyle>());
        },
      );

      test('单条数据时，应只返回一天且 style 为 CalendarReflectionsStyle', () async {
        final days = [
          const CalendarDayEntity(date: '2025-07-15', answers: [tAnswer1]),
        ];

        when(
          () => mockRepository.fetchCalendarView(start: tStart, end: tEnd),
        ).thenAnswer((_) async => days);

        final result = await useCase.execute(tStart, tEnd);

        expect(result.length, equals(1));
        expect(result['2025-07-15']!.style, isA<CalendarReflectionsStyle>());
      });
    });

    // ─── 业务逻辑 — Map key 格式 ──────────────────────────────────────────
    group('业务逻辑 — Map key 格式', () {
      test('Map 的 key 应为 yyyy-MM-dd 格式', () async {
        when(
          () => mockRepository.fetchCalendarView(start: tStart, end: tEnd),
        ).thenAnswer((_) async => tCalendarDays);

        final result = await useCase.execute(tStart, tEnd);

        final datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
        for (final key in result.keys) {
          expect(
            datePattern.hasMatch(key),
            isTrue,
            reason: 'key "$key" 不符合 yyyy-MM-dd 格式',
          );
        }
      });

      test('CalendarDayItem 的 date 字段应与 Map key 一致', () async {
        when(
          () => mockRepository.fetchCalendarView(start: tStart, end: tEnd),
        ).thenAnswer((_) async => tCalendarDays);

        final result = await useCase.execute(tStart, tEnd);

        for (final entry in result.entries) {
          expect(entry.value.date, equals(entry.key));
        }
      });
    });

    // ─── 异常分支 ──────────────────────────────────────────────────────────
    group('异常分支', () {
      test('repository 抛出 Exception 时应原样向上传播', () async {
        when(
          () => mockRepository.fetchCalendarView(start: tStart, end: tEnd),
        ).thenThrow(Exception('网络请求失败'));

        expect(
          () => useCase.execute(tStart, tEnd),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('网络请求失败'),
            ),
          ),
        );
        verify(
          () => mockRepository.fetchCalendarView(start: tStart, end: tEnd),
        ).called(1);
      });

      test('repository 抛出 TypeError 时应原样向上传播', () async {
        when(
          () => mockRepository.fetchCalendarView(start: tStart, end: tEnd),
        ).thenThrow(TypeError());

        expect(() => useCase.execute(tStart, tEnd), throwsA(isA<TypeError>()));
      });

      test('repository 返回的 Future 以错误完成时应传播该错误', () async {
        when(
          () => mockRepository.fetchCalendarView(start: tStart, end: tEnd),
        ).thenAnswer((_) async => throw StateError('数据解析异常'));

        expect(
          () => useCase.execute(tStart, tEnd),
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
      test('跨月查询应正确填充日期', () async {
        final crossMonthStart = DateTime(2025, 6, 29);
        final crossMonthEnd = DateTime(2025, 7, 2);

        when(
          () => mockRepository.fetchCalendarView(
            start: crossMonthStart,
            end: crossMonthEnd,
          ),
        ).thenAnswer((_) async => []);

        final result = await useCase.execute(crossMonthStart, crossMonthEnd);

        expect(result.length, equals(4));
        expect(result.containsKey('2025-06-29'), isTrue);
        expect(result.containsKey('2025-06-30'), isTrue);
        expect(result.containsKey('2025-07-01'), isTrue);
        expect(result.containsKey('2025-07-02'), isTrue);
      });

      test('跨年查询应正确填充日期', () async {
        final crossYearStart = DateTime(2025, 12, 30);
        final crossYearEnd = DateTime(2026, 1, 2);

        when(
          () => mockRepository.fetchCalendarView(
            start: crossYearStart,
            end: crossYearEnd,
          ),
        ).thenAnswer((_) async => []);

        final result = await useCase.execute(crossYearStart, crossYearEnd);

        expect(result.length, equals(4));
        expect(result.containsKey('2025-12-30'), isTrue);
        expect(result.containsKey('2025-12-31'), isTrue);
        expect(result.containsKey('2026-01-01'), isTrue);
        expect(result.containsKey('2026-01-02'), isTrue);
      });

      test(
        '返回数据中 answers 为空列表的 CalendarDayEntity 应被处理为 CalendarReflectionsStyle',
        () async {
          final days = [
            const CalendarDayEntity(date: '2025-07-10', answers: []),
          ];

          when(
            () => mockRepository.fetchCalendarView(start: tStart, end: tEnd),
          ).thenAnswer((_) async => days);

          final result = await useCase.execute(tStart, tEnd);

          final style = result['2025-07-10']!.style;
          expect(style, isA<CalendarReflectionsStyle>());
          expect((style as CalendarReflectionsStyle).reflections, isEmpty);
        },
      );

      test('多次调用应每次都委托给 repository', () async {
        when(
          () => mockRepository.fetchCalendarView(
            start: any(named: 'start'),
            end: any(named: 'end'),
          ),
        ).thenAnswer((_) async => []);

        await useCase.execute(tStart, tEnd);
        await useCase.execute(tStart, tEnd);

        verify(
          () => mockRepository.fetchCalendarView(
            start: any(named: 'start'),
            end: any(named: 'end'),
          ),
        ).called(2);
      });

      test('连续多天都有数据时，所有天都应为 CalendarReflectionsStyle', () async {
        final consecutiveDays = [
          const CalendarDayEntity(date: '2025-07-01', answers: [tAnswer1]),
          const CalendarDayEntity(date: '2025-07-02', answers: [tAnswer2]),
          const CalendarDayEntity(date: '2025-07-03', answers: [tAnswer1]),
        ];

        when(
          () => mockRepository.fetchCalendarView(start: tStart, end: tEnd),
        ).thenAnswer((_) async => consecutiveDays);

        final result = await useCase.execute(tStart, tEnd);

        expect(result.length, equals(3));
        for (final item in result.values) {
          expect(item.style, isA<CalendarReflectionsStyle>());
        }
      });
    });

    // ─── 接口契约 ──────────────────────────────────────────────────────────
    group('接口契约', () {
      test('UseCase 应实现 CalendarFetchReflectionUseCaseType 接口', () {
        expect(useCase, isA<CalendarFetchReflectionUseCaseType>());
      });
    });
  });
}
