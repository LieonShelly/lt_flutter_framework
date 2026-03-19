import 'package:flutter_bloc/flutter_bloc.dart';
import 'pwp_customization_state.dart';

class PwpCustomizationCubit extends Cubit<PwpCustomizationState> {
  PwpCustomizationCubit() : super(const PwpCustomizationState());

  void initDefaultOptions({
    required String defaultTemp,
    required String defaultSweet,
  }) {
    emit(
      state.copyWith(
        selectedTemperature: defaultTemp,
        selectedSweetness: defaultSweet,
      ),
    );
  }

  void selectTemperature(String temperature) {
    emit(state.copyWith(selectedTemperature: temperature));
  }

  void selectSweetness(String sweetness) {
    emit(state.copyWith(selectedSweetness: sweetness));
  }
}
