import 'package:booking/booking.dart';
import 'package:booking_domain/booking_domain.dart';
import 'package:flutter/material.dart';
import 'package:lt_uicomponent/uicomponent.dart';
import 'package:date_utl/date_utl.dart';

class AppSearchBar extends StatelessWidget {
  final ItineraryConfig? config;
  final GestureTapCallback? onTap;

  const AppSearchBar({super.key, this.config, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.grey1),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimens.paddingHorizontal,
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: _QueryText(config: config),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QueryText extends StatelessWidget {
  const _QueryText({required this.config});

  final ItineraryConfig? config;

  @override
  Widget build(BuildContext context) {
    if (config == null) {
      return const _EmptySearch();
    }
    final ItineraryConfig(:continent, :startDate, :endDate, :guests) = config!;
    if (startDate == null ||
        endDate == null ||
        guests == null ||
        continent == null) {
      return const _EmptySearch();
    }

    return Text(
      '$continent - '
      '${DateUtl.dateFormatStartEnd(DateTimeRange(start: startDate, end: endDate))} - '
      'Guests: $guests',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Icon(Icons.search),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            Applocalization.of(context).searchDestination,
            textAlign: TextAlign.start,
            style: Theme.of(context).inputDecorationTheme.hintStyle,
          ),
        ),
      ],
    );
  }
}
