import 'package:booking/booking.dart';
import 'package:booking/src/routes/routes.dart';
import 'package:booking/src/search_form/search_form_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lt_uicomponent/uicomponent.dart';

const String searchFormSubmitButtonKey = 'submit-button';

class SearchFormSubmit extends StatefulWidget {
  final SearchFormViewModel viewModel;

  const SearchFormSubmit({super.key, required this.viewModel});

  @override
  State<StatefulWidget> createState() => _SearchFormSubmitState();
}

class _SearchFormSubmitState extends State<SearchFormSubmit> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.updateItineraryConfig.addListener(_onResult);
  }

  @override
  void didUpdateWidget(covariant SearchFormSubmit oldWidget) {
    oldWidget.viewModel.updateItineraryConfig.removeListener(_onResult);
    widget.viewModel.updateItineraryConfig.addListener(_onResult);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.viewModel.updateItineraryConfig.removeListener(_onResult);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: Dimens.paddingVertical,
        left: Dimens.of(context).paddingScreenHorizontal,
        right: Dimens.of(context).paddingScreenHorizontal,
        bottom: Dimens.of(context).paddingScreenVertical,
      ),
      child: ListenableBuilder(
        listenable: widget.viewModel,
        child: SizedBox(
          height: 52,
          child: Center(child: Text(Applocalization.of(context).search)),
        ),
        builder: (context, child) {
          return FilledButton(
            key: const ValueKey(searchFormSubmitButtonKey),
            onPressed: widget.viewModel.valid
                ? widget.viewModel.updateItineraryConfig.execute
                : null,
            child: child,
          );
        },
      ),
    );
  }

  void _onResult() {
    if (widget.viewModel.updateItineraryConfig.completed) {
      widget.viewModel.updateItineraryConfig.clearResult();
      context.go(Routes.results);
    }

    if (widget.viewModel.updateItineraryConfig.error) {
      widget.viewModel.updateItineraryConfig.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Applocalization.of(context).errorWhileSavingItinerary),
          action: SnackBarAction(
            label: Applocalization.of(context).tryAgain,
            onPressed: widget.viewModel.updateItineraryConfig.execute,
          ),
        ),
      );
    }
  }
}
