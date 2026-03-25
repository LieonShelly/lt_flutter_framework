import 'package:booking/booking.dart';
import 'package:booking/src/activities/activities_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:lt_uicomponent/uicomponent.dart';
import 'activity_time_of_day.dart';

class ActivitiesTitle extends StatelessWidget {
  const ActivitiesTitle({
    super.key,
    required this.activityTimeOfDay,
    required this.viewModel,
  });

  final ActivitiesViewModel viewModel;
  final ActivityTimeOfDay activityTimeOfDay;

  @override
  Widget build(BuildContext context) {
    final list = switch (activityTimeOfDay) {
      ActivityTimeOfDay.daytime => viewModel.daytimeActivities,
      ActivityTimeOfDay.evening => viewModel.eveningActivities,
    };
    if (list.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox());
    }
    return SliverToBoxAdapter(
      child: Padding(
        padding: Dimens.of(context).edgeInsetsScreenHorizontal,
        child: Text(_label(context)),
      ),
    );
  }

  String _label(BuildContext context) => switch (activityTimeOfDay) {
    ActivityTimeOfDay.daytime => Applocalization.of(context).daytime,
    ActivityTimeOfDay.evening => Applocalization.of(context).evening,
  };
}
