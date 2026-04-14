import 'package:mocktail/mocktail.dart';
import 'package:reflection_domain/reflection_domain.dart';
import 'package:test/test.dart';

// ─── Mock ────────────────────────────────────────────────────────────────────
class MockReflectionRepository extends Mock implements ReflectionRepository {}

void main() {
  late MockReflectionRepository mockRepository;
  late FetchWeeklyReportsUseCase useCase;

  // ─── Fixtures ──────────────────────────────────────────────────────────────
  const tPagination = PaginationEntity(
    limit: 20,
    hasMore: true,
    nextCursor: '2024-W36',
  );

  const tPaginationNoMore = PaginationEntity(limit: 20, hasMore: false);

  final tReport1 = WeeklyReportEntity(
    id: 'report-1',
    week: '2024-W43',
    periodStart: '2024-10-21',
    periodEnd: '2024-10-27',
    reflectionCount: 9,
    readAt: DateTime(2026, 3, 18, 3, 20),
    summary: '这一周你记录了 9 次反思...',
    icon: const WeeklyReportIconEntity(
      id: 'icon-1',
      url: 'https://example.com/icon1.png',
    ),
  );

  const tReport2 = WeeklyReportEntity(
    id: 'report-2',
    week: '2024-W42',
    periodStart: '2024-10-14',
    periodEnd: '2024-10-20',
    reflectionCount: 5,
  );

  final tReportList = WeeklyReportListEntity(
    reports: [tReport1, tReport2],
    pagination: tPagination,
  );

  const tEmptyReportList = WeeklyReportListEntity(
    reports: [],
    pagination: tPaginationNoMore,
  );

  setUp(() {
    mockRepository = MockReflectionRepository();
    useCase = FetchWeeklyReportsUseCase(mockRepository);
  });

  group('FetchWeeklyReportsUseCase', () {
    // ─── 正常路径 ──────────────────────────────────────────────────────────
    group('正常路径', () {
      test(
        '应调用 repository.fetchWeeklyReports 并返回 WeeklyReportListEntity',
        () async {
          when(
            () => mockRepository.fetchWeeklyReports(
              limit: null,
              cursor: null,
              isRead: null,
            ),
          ).thenAnswer((_) async => tReportList);

          final result = await useCase.execute();

          expect(result.reports.length, equals(2));
          expect(result.pagination.hasMore, isTrue);
          verify(
            () => mockRepository.fetchWeeklyReports(
              limit: null,
              cursor: null,
              isRead: null,
            ),
          ).called(1);
          verifyNoMoreInteractions(mockRepository);
        },
      );

      test('应正确透传所有参数给 repository', () async {
        when(
          () => mockRepository.fetchWeeklyReports(
            limit: 10,
            cursor: '2024-W40',
            isRead: false,
          ),
        ).thenAnswer((_) async => tReportList);

        await useCase.execute(limit: 10, cursor: '2024-W40', isRead: false);

        verify(
          () => mockRepository.fetchWeeklyReports(
            limit: 10,
            cursor: '2024-W40',
            isRead: false,
          ),
        ).called(1);
      });

      test('应返回包含完整关联数据的报告（含 icon 和 summary）', () async {
        final listWithFullData = WeeklyReportListEntity(
          reports: [tReport1],
          pagination: tPaginationNoMore,
        );

        when(
          () => mockRepository.fetchWeeklyReports(
            limit: null,
            cursor: null,
            isRead: null,
          ),
        ).thenAnswer((_) async => listWithFullData);

        final result = await useCase.execute();

        final report = result.reports.first;
        expect(report.icon, isNotNull);
        expect(report.icon!.url, equals('https://example.com/icon1.png'));
        expect(report.summary, isNotNull);
        expect(report.readAt, isNotNull);
        expect(report.isRead, isTrue);
      });

      test('应返回可选字段为 null 的报告（最小数据）', () async {
        final listWithMinimalData = WeeklyReportListEntity(
          reports: [tReport2],
          pagination: tPaginationNoMore,
        );

        when(
          () => mockRepository.fetchWeeklyReports(
            limit: null,
            cursor: null,
            isRead: null,
          ),
        ).thenAnswer((_) async => listWithMinimalData);

        final result = await useCase.execute();

        final report = result.reports.first;
        expect(report.readAt, isNull);
        expect(report.summary, isNull);
        expect(report.icon, isNull);
        expect(report.isRead, isFalse);
      });
    });

    // ─── 异常分支 ──────────────────────────────────────────────────────────
    group('异常分支', () {
      test('repository 抛出 Exception 时应原样向上传播', () async {
        when(
          () => mockRepository.fetchWeeklyReports(
            limit: any(named: 'limit'),
            cursor: any(named: 'cursor'),
            isRead: any(named: 'isRead'),
          ),
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
        verify(
          () => mockRepository.fetchWeeklyReports(
            limit: any(named: 'limit'),
            cursor: any(named: 'cursor'),
            isRead: any(named: 'isRead'),
          ),
        ).called(1);
      });

      test('repository 抛出 TypeError 时应原样向上传播', () async {
        when(
          () => mockRepository.fetchWeeklyReports(
            limit: any(named: 'limit'),
            cursor: any(named: 'cursor'),
            isRead: any(named: 'isRead'),
          ),
        ).thenThrow(TypeError());

        expect(() => useCase.execute(), throwsA(isA<TypeError>()));
      });

      test('repository 返回的 Future 以错误完成时应传播该错误', () async {
        when(
          () => mockRepository.fetchWeeklyReports(
            limit: any(named: 'limit'),
            cursor: any(named: 'cursor'),
            isRead: any(named: 'isRead'),
          ),
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
      test('reports 为空列表时应正常返回', () async {
        when(
          () => mockRepository.fetchWeeklyReports(
            limit: any(named: 'limit'),
            cursor: any(named: 'cursor'),
            isRead: any(named: 'isRead'),
          ),
        ).thenAnswer((_) async => tEmptyReportList);

        final result = await useCase.execute();

        expect(result.reports, isEmpty);
        expect(result.pagination.hasMore, isFalse);
      });

      test('所有可选参数都传 null 时应正常调用', () async {
        when(
          () => mockRepository.fetchWeeklyReports(
            limit: null,
            cursor: null,
            isRead: null,
          ),
        ).thenAnswer((_) async => tEmptyReportList);

        final result = await useCase.execute(
          limit: null,
          cursor: null,
          isRead: null,
        );

        expect(result, isA<WeeklyReportListEntity>());
      });

      test('limit 为边界值时应正常传递', () async {
        when(
          () => mockRepository.fetchWeeklyReports(
            limit: 1,
            cursor: null,
            isRead: null,
          ),
        ).thenAnswer((_) async => tEmptyReportList);

        await useCase.execute(limit: 1);

        verify(
          () => mockRepository.fetchWeeklyReports(
            limit: 1,
            cursor: null,
            isRead: null,
          ),
        ).called(1);
      });

      test('isRead 为 true 时应正确传递', () async {
        when(
          () => mockRepository.fetchWeeklyReports(
            limit: null,
            cursor: null,
            isRead: true,
          ),
        ).thenAnswer((_) async => tEmptyReportList);

        await useCase.execute(isRead: true);

        verify(
          () => mockRepository.fetchWeeklyReports(
            limit: null,
            cursor: null,
            isRead: true,
          ),
        ).called(1);
      });

      test('isRead 为 false 时应正确传递', () async {
        when(
          () => mockRepository.fetchWeeklyReports(
            limit: null,
            cursor: null,
            isRead: false,
          ),
        ).thenAnswer((_) async => tEmptyReportList);

        await useCase.execute(isRead: false);

        verify(
          () => mockRepository.fetchWeeklyReports(
            limit: null,
            cursor: null,
            isRead: false,
          ),
        ).called(1);
      });

      test('cursor 包含特殊格式（YYYY-Wnn）时应正常传递', () async {
        when(
          () => mockRepository.fetchWeeklyReports(
            limit: null,
            cursor: '2024-W01',
            isRead: null,
          ),
        ).thenAnswer((_) async => tEmptyReportList);

        await useCase.execute(cursor: '2024-W01');

        verify(
          () => mockRepository.fetchWeeklyReports(
            limit: null,
            cursor: '2024-W01',
            isRead: null,
          ),
        ).called(1);
      });

      test('pagination.nextCursor 为 null 时应正常返回', () async {
        const listNoNextCursor = WeeklyReportListEntity(
          reports: [],
          pagination: PaginationEntity(limit: 20, hasMore: false),
        );

        when(
          () => mockRepository.fetchWeeklyReports(
            limit: any(named: 'limit'),
            cursor: any(named: 'cursor'),
            isRead: any(named: 'isRead'),
          ),
        ).thenAnswer((_) async => listNoNextCursor);

        final result = await useCase.execute();

        expect(result.pagination.nextCursor, isNull);
        expect(result.pagination.hasMore, isFalse);
      });

      test('多次调用应每次都委托给 repository', () async {
        when(
          () => mockRepository.fetchWeeklyReports(
            limit: any(named: 'limit'),
            cursor: any(named: 'cursor'),
            isRead: any(named: 'isRead'),
          ),
        ).thenAnswer((_) async => tEmptyReportList);

        await useCase.execute();
        await useCase.execute(limit: 10);
        await useCase.execute(isRead: true);

        verify(
          () => mockRepository.fetchWeeklyReports(
            limit: any(named: 'limit'),
            cursor: any(named: 'cursor'),
            isRead: any(named: 'isRead'),
          ),
        ).called(3);
      });
    });

    // ─── 接口契约 ──────────────────────────────────────────────────────────
    group('接口契约', () {
      test('UseCase 应实现 FetchWeeklyReportsUseCaseType 接口', () {
        expect(useCase, isA<FetchWeeklyReportsUseCaseType>());
      });
    });
  });
}
