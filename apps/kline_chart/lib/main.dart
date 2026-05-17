import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet_data/wallet_data.dart';

import 'src/kline/kline_chart_page.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        klineRepositoryProvider.overrideWith(
          (ref) {
            const dataSource = MockKlineRemoteDataSource();
            final store = KlineStore();
            return KlineRepositoryImpl(dataSource, store);
          },
        ),
      ],
      child: const KlineChartApp(),
    ),
  );
}

class KlineChartApp extends StatelessWidget {
  const KlineChartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'K Line Chart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const KlineChartPage(),
    );
  }
}
