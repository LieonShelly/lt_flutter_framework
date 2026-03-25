import 'package:booking/booking.dart';
import 'package:booking/src/activities/activities_viewmodel.dart';
import 'package:booking/src/activities/activity_entry.dart';
import 'package:flutter/material.dart';
import 'package:lt_uicomponent/uicomponent.dart';
import 'package:go_router/go_router.dart';
import 'activity_time_of_day.dart';

class ActivitiesList extends StatelessWidget {
  const ActivitiesList({
    super.key,
    required this.viewModel,
    required this.activityTimeOfDay,
  });

  final ActivitiesViewModel viewModel;
  final ActivityTimeOfDay activityTimeOfDay;

  @override
  Widget build(BuildContext context) {
    final list = switch (activityTimeOfDay) {
      ActivityTimeOfDay.daytime => viewModel.daytimeActivities,
      ActivityTimeOfDay.evening => viewModel.eveningActivities,
    };
    return SliverPadding(
      padding: EdgeInsets.only(
        top: Dimens.paddingVertical,
        left: Dimens.of(context).paddingScreenHorizontal,
        right: Dimens.of(context).paddingScreenHorizontal,
        bottom: Dimens.paddingVertical,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final activity = list[index];
          return Padding(
            padding: EdgeInsets.only(bottom: index < list.length - 1 ? 20 : -0),
            child: ActivityEntry(
              activity: activity,
              selected: viewModel.selectedActivities.contains(activity.ref),
              onChanged: (value) {
                if (value!) {
                  viewModel.addActivity(activity.ref);
                } else {
                  viewModel.removeActivity(activity.ref);
                }
              },
            ),
          );
        }),
      ),
    );
  }
}
