import 'package:booking/src/search_form/search_form_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:lt_uicomponent/uicomponent.dart';

const String removeGuestsKey = 'remove-guests';
const String addGuestsKey = 'add-guests';

class SearchFormGuests extends StatelessWidget {
  final SearchFormViewModel viewModel;

  const SearchFormGuests({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: Dimens.paddingVertical,
        left: Dimens.of(context).paddingScreenHorizontal,
        right: Dimens.of(context).paddingScreenHorizontal,
      ),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsetsGeometry.symmetric(
            horizontal: Dimens.paddingHorizontal,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Who', style: Theme.of(context).textTheme.titleMedium),
              _QuantitySelector(viewModel),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final SearchFormViewModel viewModel;
  const _QuantitySelector(this.viewModel);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            key: const ValueKey(removeGuestsKey),
            onTap: () {
              viewModel.guests--;
            },
            child: const Icon(
              Icons.remove_circle_outline,
              color: AppColors.grey3,
            ),
          ),
          ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) => Text(
              viewModel.guests.toString(),
              style: viewModel.guests == 0
                  ? Theme.of(context).inputDecorationTheme.hintStyle
                  : Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          InkWell(
            key: const ValueKey(addGuestsKey),
            onTap: () {
              viewModel.guests++;
            },
            child: const Icon(Icons.add_circle_outline, color: AppColors.grey3),
          ),
        ],
      ),
    );
  }
}
