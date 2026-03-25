import 'package:booking_domain/booking_domain.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:common/common.dart';

class BookingViewModel extends ChangeNotifier {
  final BookingCreateUseCase _createUseCase;
  final BookingShareUseCase _shareUseCase;
  final ItineraryConfigRepository _itineraryConfigRepository;
  final BookingRepository _bookingRepository;
  final _log = Logger('BookingViewModel');
  Booking? _booking;
  Booking? get booking => _booking;
  late final Command0 createBooking;
  late final Command1<void, int> loadingBooking;
  late final Command0 shareBooking;

  BookingViewModel({
    required BookingCreateUseCase creatingBookingUseCase,
    required BookingShareUseCase shareBookingUseCase,
    required ItineraryConfigRepository itineraryConfigRepository,
    required BookingRepository bookingRepository,
  }) : _createUseCase = creatingBookingUseCase,
       _shareUseCase = shareBookingUseCase,
       _itineraryConfigRepository = itineraryConfigRepository,
       _bookingRepository = bookingRepository {
    createBooking = Command0(_createBooking);
    loadingBooking = Command1(_load);
    shareBooking = Command0(() => _shareUseCase.shareBooking(_booking!));
  }

  Future<Result<void>> _createBooking() async {
    _log.fine('loading booking');
    final itineraryConfig = await _itineraryConfigRepository
        .getItineraryConfig();

    switch (itineraryConfig) {
      case Ok<ItineraryConfig>():
        final result = await _createUseCase.createFrom(itineraryConfig.value);
        switch (result) {
          case Ok<Booking>():
            _booking = result.value;
            notifyListeners();
            return Result.ok(null);
          case Error<Booking>():
            _log.warning('Booking error: ${result.error}');
            notifyListeners();
            return Result.error(result.error);
        }
      case Error<ItineraryConfig>():
        _log.warning('ItineraryConfig error: ${itineraryConfig.error}');
        notifyListeners();
        return Result.error(itineraryConfig.error);
    }
  }

  Future<Result<void>> _load(int id) async {
    final result = await _bookingRepository.getBooking(id);
    switch (result) {
      case Ok<Booking>():
        _booking = result.value;
        notifyListeners();
      case Error<Booking>():
        _log.warning('Failed to load booking $id');
    }
    return result;
  }
}
