import 'package:booking/booking.dart';
import 'package:booking_domain/booking_domain.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lt_uicomponent/uicomponent.dart';
import 'package:date_utl/date_utl.dart';
import 'package:common/common.dart';

class BookingHeader extends StatelessWidget {
  final Booking booking;

  const BookingHeader({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Top(booking: booking),
        Padding(
          padding: Dimens.of(context).edgeInsetsScreenHorizontal,
          child: Text(
            booking.destination.knownFor,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        const SizedBox(height: Dimens.paddingVertical),
        _Tags(booking: booking),
        const SizedBox(height: Dimens.paddingVertical),
        Padding(
          padding: Dimens.of(context).edgeInsetsScreenHorizontal,
          child: Text(
            Applocalization.of(context).yourChosenActivities,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ],
    );
  }
}

class _Top extends StatelessWidget {
  final Booking booking;

  const _Top({required this.booking});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _HeaderImage(booking: booking),
          const _Gradient(),
          _Headline(booking: booking),
          Positioned(
            right: Dimens.of(context).paddingScreenHorizontal,
            top: Dimens.of(context).paddingScreenVertical,
            child: const SafeArea(top: true, child: HomeButton(blur: true)),
          ),
        ],
      ),
    );
  }
}

class _Tags extends StatelessWidget {
  const _Tags({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final chipColor = switch (brightness) {
      Brightness.dark => AppColors.whiteTransparent,
      Brightness.light => AppColors.blackTransparent,
    };
    return Padding(
      padding: Dimens.of(context).edgeInsetsScreenHorizontal,
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: booking.destination.tags
            .map(
              (tag) => TagChip(
                tag: tag,
                fontSize: 16,
                height: 32,
                chipColor: chipColor,
                onChipColor: Theme.of(context).colorScheme.onSurface,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  final Booking booking;

  const _Headline({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.bottomStart,
      child: Padding(
        padding: Dimens.of(context).edgeInsetsScreenSymmetric,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.destination.name,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Text(
              DateUtl.dateFormatStartEnd(
                DateTimeRange(start: booking.startDate, end: booking.endDate),
              ),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderImage extends StatelessWidget {
  final Booking booking;

  const _HeaderImage({required this.booking});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      fit: BoxFit.fitWidth,
      imageUrl: booking.destination.imageUrl,
      errorListener: imageErrorListener,
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey,
            size: 60,
          ),
        ),
      ),
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _Gradient extends StatelessWidget {
  const _Gradient();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Theme.of(context).colorScheme.surface],
        ),
      ),
    );
  }
}
