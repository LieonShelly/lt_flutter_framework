import 'package:booking/src/localization/applocalization.dart';
import 'package:booking/src/search_form/search_form_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:lt_uicomponent/uicomponent.dart';
import 'package:date_utl/date_utl.dart';

class SearchFormDate extends StatelessWidget {
  final SearchFormViewModel viewModel;

  const SearchFormDate({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: Dimens.paddingVertical,
        left: Dimens.of(context).paddingScreenHorizontal,
        right: Dimens.of(context).paddingScreenHorizontal,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          showDateRangePicker(
            context: context,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(Duration(days: 365)),
          ).then((dateRange) => viewModel.dateRange = dateRange);
        },
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimens.paddingHorizontal,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Applocalization.of(context).when,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                ListenableBuilder(
                  listenable: viewModel,
                  builder: (context, _) {
                    final dateRange = viewModel.dataRange;
                    if (dateRange != null) {
                      return Text(
                        DateUtl.dateFormatStartEnd(dateRange),
                        style: Theme.of(context).textTheme.bodyLarge,
                      );
                    } else {
                      return Text(
                        Applocalization.of(context).addDates,
                        style: Theme.of(context).textTheme.bodyLarge,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
