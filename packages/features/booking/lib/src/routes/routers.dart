import 'package:booking/booking.dart';
import 'package:booking/src/activities/activities_screen.dart';
import 'package:booking/src/activities/activities_viewmodel.dart';
import 'package:booking/src/booking/booking_screen.dart';
import 'package:booking/src/booking/booking_viewmodel.dart';
import 'package:booking/src/home/home_screen.dart';
import 'package:booking/src/home/home_viewmodel.dart';
import 'package:booking/src/results/results_screen.dart';
import 'package:booking/src/results/results_viewmodel.dart';
import 'package:booking/src/search_form/search_form_screen.dart';
import 'package:booking/src/search_form/search_form_viewmodel.dart';
import 'package:booking_domain/booking_domain.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

GoRouter router(AuthRepository authRepository) => GoRouter(
  initialLocation: Routes.home,
  // redirect: _redirect,
  // refreshListenable: authRepository,
  routes: [
    GoRoute(
      path: Routes.home,
      redirect: _redirect,
      builder: (context, state) {
        final viewModel = HomeViewmodel(
          bookingRepository: context.read(),
          userRepository: context.read(),
        );
        return HomeScreen(viewmodel: viewModel);
      },
      routes: [
        GoRoute(
          path: Routes.searchRelative,
          builder: (context, state) {
            final viewModel = SearchFormViewModel(
              continentRepository: context.read(),
              itineraryConfigRepository: context.read(),
            );
            return SearchFormScreen(viewModel: viewModel);
          },
        ),
        GoRoute(
          path: Routes.bookingRelative,
          builder: (context, state) {
            final viewModel = BookingViewModel(
              creatingBookingUseCase: context.read(),
              shareBookingUseCase: context.read(),
              itineraryConfigRepository: context.read(),
              bookingRepository: context.read(),
            );
            viewModel.createBooking.execute();
            return BookingScreen(viewModel: viewModel);
          },
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                final viewModel = BookingViewModel(
                  creatingBookingUseCase: context.read(),
                  shareBookingUseCase: context.read(),
                  itineraryConfigRepository: context.read(),
                  bookingRepository: context.read(),
                );
                viewModel.loadingBooking.execute(id);
                return BookingScreen(viewModel: viewModel);
              },
            ),
          ],
        ),

        GoRoute(
          path: Routes.resultsRelative,
          builder: (context, state) {
            final viewModel = ResultsViewModel(context.read(), context.read());
            return ResultsScreen(viewModel: viewModel);
          },
        ),

        GoRoute(
          path: Routes.activitiesRelative,
          builder: (context, state) {
            final viewModel = ActivitiesViewModel(
              activityRepository: context.read(),
              itineraryConfigRepository: context.read(),
            );
            return ActivitiesScreen(viewModel: viewModel);
          },
        ),
      ],
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
