import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lt_uicomponent/uicomponent.dart';
import 'package:thread/src/checkout/pwp_customization_cubit.dart';
import 'package:thread/src/checkout/pwp_customization_state.dart';

class PwpBottomSheet extends StatelessWidget {
  final Map<String, dynamic> productInfo;

  const PwpBottomSheet({super.key, required this.productInfo});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PwpCustomizationCubit()
        ..initDefaultOptions(
          defaultTemp: productInfo['default_temp'] ?? "Normal",
          defaultSweet: productInfo['default_sweet'] ?? 'Normal',
        ),
      child: const _CustomizationContentView(),
    );
  }
}

class _CustomizationContentView extends StatelessWidget {
  const _CustomizationContentView();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "data",
            style: AppTextStyle.feltTipSeniorRegular(
              fontSize: 32,
              color: Color(0x00000000),
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(height: 20),
          const Text('Temperature'),
          BlocBuilder<PwpCustomizationCubit, PwpCustomizationState>(
            builder: (context, state) {
              return Row(
                children: [
                  _buildOptionBtn(context, "Hot", state.selectedTemperature),
                  _buildOptionBtn(context, "normal", state.selectedTemperature),
                  _buildOptionBtn(
                    context,
                    "Less Iced",
                    state.selectedTemperature,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionBtn(
    BuildContext context,
    String title,
    String currentSlected,
  ) {
    final isSelected = title == currentSlected;
    return GestureDetector(
      onTap: () {
        context.read<PwpCustomizationCubit>().selectTemperature(title);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.red,
          border: isSelected ? Border.all(color: Colors.blue) : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          title,
          style: AppTextStyle.feltTipSeniorRegular(
            color: isSelected ? Colors.blue : Colors.black,
            fontSize: 32,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
