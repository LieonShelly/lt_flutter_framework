import 'package:booking/booking.dart';
import 'package:booking/src/home/home_screen.dart';
import 'package:booking/src/home/home_viewmodel.dart';
import 'package:booking_domain/booking_domain.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

GoRouter router(AuthRepository authRepository) => GoRouter(
  initialLocation: Routes.home,
  redirect: _redirect,
  refreshListenable: authRepository,
  routes: [
    GoRoute(
      path: Routes.home,
      builder: (context, state) {
        final viewModel = HomeViewmodel(
          bookingRepository: context.read(),
          userRepository: context.read(),
        );
        return HomeScreen(viewmodel: viewModel);
      },
    ),
  ],
);

Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  final loggedIn = await context.read<AuthRepository>().isAuthenticated;
  final loggingIn = state.matchedLocation == Routes.login;
  if (!loggedIn) {
    return Routes.login;
  }
  if (loggingIn) {
    return Routes.home;
  }
  return null;
}
