import 'dart:io';

import 'package:booking_data/booking_data.dart';
import 'package:booking_domain/booking_domain.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:lt_network/network.dart';

List<SingleChildWidget> _sharedProviders = [
  Provider(
    lazy: true,
    create: (context) => BookingCreateUseCase(
      destinationRepository: context.read(),
      activityRepository: context.read(),
      bookingRepository: context.read(),
    ),
  ),
  Provider(
    lazy: true,
    create: (context) => BookingShareUseCase.withSharePlus(),
  ),
];

List<SingleChildWidget> get providersRemote {
  const isProduction = bool.fromEnvironment('dart.vm.product');
  final _tokenStorageProvider = isProduction
      ? SecureTokenStorage()
      : MockTokenStorage();
  final apiClient = HttpApiClient(
    baseUrl: 'htpp:localhost:8080',
    tokenStorage: _tokenStorageProvider,
  );
  return [
    Provider(create: (context) => RemoteDatasource(apiClient: apiClient)),
    Provider(create: (context) => SharedPreferencesService()),
    Provider(
      create: (context) =>
          DestinationRepositoryRemote(apiClient: context.read())
              as DestinationRepository,
    ),

    Provider(
      create: (context) =>
          ContinentRepositoryRemote(apiClient: context.read())
              as ContinentRepository,
    ),
    Provider(
      create: (context) =>
          ActivityRepositoryRemote(apiClient: context.read())
              as ActivityRepository,
    ),
    Provider.value(
      value: ItineraryConfigRepositoryMemory() as ItineraryConfigRepository,
    ),
    Provider(
      create: (context) =>
          BookingRepositoryRemote(apiClient: context.read())
              as BookingRepository,
    ),
    Provider(
      create: (context) =>
          UserRepositoryRemote(apiClient: context.read()) as UserRepository,
    ),
    ..._sharedProviders,
  ];
}

List<SingleChildWidget> get providersLocal {
  return [
    ChangeNotifierProvider.value(value: AuthRepositoryDev() as AuthRepository),
    Provider.value(value: LocalDataService()),
    Provider(
      create: (context) =>
          DestinationRepositoryLocal(localDataService: context.read())
              as DestinationRepository,
    ),
    Provider(
      create: (context) =>
          ContinentRepositoryLocal(localDataService: context.read())
              as ContinentRepository,
    ),
    Provider(
      create: (context) =>
          ActivityRepositoryLocal(localDataService: context.read())
              as ActivityRepository,
    ),
    Provider(
      create: (context) =>
          BookingRepositoryLocal(localDataService: context.read())
              as BookingRepository,
    ),
    Provider.value(
      value: ItineraryConfigRepositoryMemory() as ItineraryConfigRepository,
    ),
    Provider(
      create: (context) =>
          UserRepositoryLocal(localDataService: context.read())
              as UserRepository,
    ),
    ..._sharedProviders,
  ];
}
