import 'package:feature_core/feature_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/src/route.dart';
import 'package:wallets/src/market_ticker_page.dart';

class WalletsRouteConfig extends FeatureRouteConfig {
  WalletsRouteConfig();

  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: AppRoutePath.market,
      pageBuilder: (context, state) {
        final page = MarketTickerPage();
        return MaterialPage(key: state.pageKey, child: page);
      },
    ),
  ];
}
