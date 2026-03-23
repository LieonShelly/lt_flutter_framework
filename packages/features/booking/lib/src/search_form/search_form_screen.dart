import 'package:booking/src/routes/routes.dart';
import 'package:booking/src/search_bar.dart';
import 'package:booking/src/search_form/search_form_continent.dart';
import 'package:booking/src/search_form/search_form_date.dart';
import 'package:booking/src/search_form/search_form_guests.dart';
import 'package:booking/src/search_form/search_form_submit.dart';
import 'package:booking/src/search_form/search_form_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lt_uicomponent/uicomponent.dart';

class SearchFormScreen extends StatelessWidget {
  const SearchFormScreen({super.key, required this.viewModel});
  final SearchFormViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go(Routes.home);
      },
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SafeArea(
              top: true,
              bottom: false,
              child: Padding(
                padding: EdgeInsets.only(
                  top: Dimens.of(context).paddingScreenVertical,
                  left: Dimens.of(context).paddingScreenHorizontal,
                  right: Dimens.of(context).paddingScreenHorizontal,
                  bottom: Dimens.paddingVertical,
                ),
                child: const AppSearchBar(),
              ),
            ),
            SearchFormContinent(viewModel: viewModel),
            SearchFormDate(viewModel: viewModel),
            SearchFormGuests(viewModel: viewModel),
            SearchFormSubmit(viewModel: viewModel),
          ],
        ),
      ),
    );
  }
}
