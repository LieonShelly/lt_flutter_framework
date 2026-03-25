import 'package:booking_domain/booking_domain.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:common/common.dart';

class ResultsViewModel extends ChangeNotifier {
  final _log = Logger('ResultsViewModel');
  final DestinationRepository _destinationRepository;
  final ItineraryConfigRepository _itineraryConfigRepository;
  List<Destination> _destinations = [];
  List<Destination> get destinations => _destinations;
  ItineraryConfig? _itineraryConfig;
  ItineraryConfig get config => _itineraryConfig ?? const ItineraryConfig();
  late final Command0 search;
  late final Command1<void, String> updateItineraryConfig;

  ResultsViewModel(
    DestinationRepository destinationRepository,
    ItineraryConfigRepository itineraryConfigRepository,
  ) : _destinationRepository = destinationRepository,
      _itineraryConfigRepository = itineraryConfigRepository {
    search = Command0(_search)..execute();
    updateItineraryConfig = Command1<void, String>(_updateItineraryConfig);
  }

  Future<Result<void>> _search() async {
    final resultConfig = await _itineraryConfigRepository.getItineraryConfig();
    switch (resultConfig) {
      case Error<ItineraryConfig>():
        _log.warning(
          'Failed to load stored ItineraryConfig',
          resultConfig.error,
        );
        return resultConfig;
      case Ok<ItineraryConfig>():
    }
    _itineraryConfig = resultConfig.value;
    notifyListeners();

    final result = await _destinationRepository.getDestinations();
    switch (result) {
      case Ok():
        {
          // If the result is Ok, update the list of destinations
          _destinations = result.value
              .where(
                (destination) =>
                    destination.continent == _itineraryConfig!.continent,
              )
              .toList();
          _log.fine('Destinations (${_destinations.length}) loaded');
        }
      case Error():
        {
          _log.warning('Failed to load destinations', result.error);
        }
    }
    notifyListeners();
    return result;
  }

  Future<Result<void>> _updateItineraryConfig(String destinationRef) async {
    final resultConfig = await _itineraryConfigRepository.getItineraryConfig();
    switch (resultConfig) {
      case Ok():
        break;
      case Error<ItineraryConfig>():
        _log.warning(
          'Failed to load stored ItineraryConfig',
          resultConfig.error,
        );
        return resultConfig;
    }

    final itineraryConfig = resultConfig.value;
    final result = await _itineraryConfigRepository.setItineraryConfig(
      itineraryConfig.copyWith(destination: destinationRef, activities: []),
    );
    if (result is Error) {
      _log.warning('Failed to store ItineraryConfig', result.error);
    }
    return result;
  }
}
