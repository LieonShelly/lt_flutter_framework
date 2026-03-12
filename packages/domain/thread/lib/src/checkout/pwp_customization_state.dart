import 'package:equatable/equatable.dart';

class PwpCustomizationState extends Equatable {
  final String selectedTemperature;
  final String selectedSweetness;

  const PwpCustomizationState({
    this.selectedSweetness = "",
    this.selectedTemperature = "",
  });

  PwpCustomizationState copyWith({
    String? selectedTemperature,
    String? selectedSweetness,
  }) {
    return PwpCustomizationState(
      selectedSweetness: selectedSweetness ?? this.selectedSweetness,
      selectedTemperature: selectedTemperature ?? this.selectedTemperature,
    );
  }

  @override
  List<Object?> get props => [selectedSweetness, selectedTemperature];
}
