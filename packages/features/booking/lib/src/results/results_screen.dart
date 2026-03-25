import 'package:booking/booking.dart';
import 'package:booking/src/results/result_card.dart';
import 'package:booking/src/results/results_viewmodel.dart';
import 'package:booking/src/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lt_uicomponent/uicomponent.dart';

class ResultsScreen extends StatefulWidget {
  final ResultsViewModel viewModel;

  const ResultsScreen({super.key, required this.viewModel});

  @override
  State<StatefulWidget> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  @override
  void initState() {
    widget.viewModel.updateItineraryConfig.addListener(_onReuslt);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ResultsScreen oldWidget) {
    widget.viewModel.removeListener(_onReuslt);
    widget.viewModel.updateItineraryConfig.addListener(_onReuslt);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.viewModel.updateItineraryConfig.removeListener(_onReuslt);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }

  void _onReuslt() {
    if (widget.viewModel.updateItineraryConfig.completed) {
      widget.viewModel.updateItineraryConfig.clearResult();
      context.go(Routes.activities);
    }
    if (widget.viewModel.updateItineraryConfig.error) {
      widget.viewModel.updateItineraryConfig.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Applocalization.of(context).errorWhileSavingItinerary),
        ),
      );
    }
  }
}

class _AppSearchBar extends StatelessWidget {
  final ResultsScreen widget;
  const _AppSearchBar({required this.widget});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(
          top: Dimens.of(context).paddingScreenVertical,
          bottom: Dimens.mobile.paddingScreenVertical,
        ),
        child: AppSearchBar(
          config: widget.viewModel.config,
          onTap: () {
            context.pop();
          },
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  final ResultsViewModel viewModel;

  const _Grid({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8,
        childAspectRatio: 182 / 222,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final destination = viewModel.destinations[index];

        return ResultCard(
          destination: destination,
          onTap: () {
            viewModel.updateItineraryConfig.execute(destination.ref);
          },
        );
      }),
    );
  }
}
