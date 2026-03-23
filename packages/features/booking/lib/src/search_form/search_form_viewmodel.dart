import 'package:booking_domain/booking_domain.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:common/common.dart';

class SearchFormViewModel extends ChangeNotifier {
  final _log = Logger('SearchFormViewModel');
  final ContinentRepository _continentRepository;
  final ItineraryConfigRepository _itineraryConfigRepository;
  List<Continent> _continents = [];
  String? _selectedContinent;
  DateTimeRange? _dateTimeRange;
  int _guests = 0;
  String number = "";
  bool get valid =>
      _guests > 0 && _selectedContinent != null && _dateTimeRange != null;
  List<Continent> get continents => _continents;
  String? get selectedContinent => _selectedContinent;

  set selectedContinent(String? continent) {
    _selectedContinent = continent;
    notifyListeners();
  }

  DateTimeRange? get dataRange => _dateTimeRange;

  set dateRange(DateTimeRange? dateRange) {
    _dateTimeRange = dateRange;
    number = dataRange!.toString();
    notifyListeners();
  }

  int get guests => _guests;

  set guests(int quantity) {
    if (quantity < 0) {
      _guests = 0;
    } else {
      _guests = quantity;
    }
    _log.finest('Set guests number: $_guests');
    notifyListeners();
  }

  late final Command0 load;
  late final Command0 updateItineraryConfig;

  SearchFormViewModel({
    required ContinentRepository continentRepository,
    required ItineraryConfigRepository itineraryConfigRepository,
  }) : _continentRepository = continentRepository,
       _itineraryConfigRepository = itineraryConfigRepository {
    updateItineraryConfig = Command0(_loadItineraryConfig);
    load = Command0(_load)..execute();
  }

  Future<Result<void>> _load() async {
    final result = await _loadContinents();
    if (result is Error) {
      return result;
    }
    return await _loadItineraryConfig();
  }

  Future<Result<void>> _loadContinents() async {
    final result = await _continentRepository.getContinents();
    switch (result) {
      case Ok():
        _continents = result.value;
        _log.fine('Continents (${_continents.length}) loaded');
      case Error():
        _log.warning('Failed to load continents', result.error);
    }
    notifyListeners();
    return result;
  }

  Future<Result<void>> _loadItineraryConfig() async {
    final result = await _itineraryConfigRepository.getItineraryConfig();
    switch (result) {
      case Ok<ItineraryConfig>():
        final itineraryConfig = result.value;
        _selectedContinent = itineraryConfig.continent;
        if (itineraryConfig.startDate != null &&
            itineraryConfig.endDate != null) {
          _dateTimeRange = DateTimeRange(
            start: itineraryConfig.startDate!,
            end: itineraryConfig.endDate!,
          );
        }
        _guests = itineraryConfig.guests ?? 0;
        _log.fine('ItineraryConfig loaded');
        notifyListeners();
      case Error<ItineraryConfig>():
        _log.warning('Failed to load stored ItineraryConfig', result.error);
    }
    return result;
  }

  Future<Result<void>> _updateItineraryConfig() async {
    assert(valid, "called when valid was false");
    final result = await _itineraryConfigRepository.setItineraryConfig(
      ItineraryConfig(
        continent: _selectedContinent,
        startDate: _dateTimeRange!.start,
        endDate: _dateTimeRange!.end,
        guests: _guests,
      ),
    );
    switch (result) {
      case Ok<void>():
        _log.fine('ItineraryConfig saved');
      case Error<void>():
        _log.warning('Failed to store ItineraryConfig', result.error);
    }
    return result;
  }
}
