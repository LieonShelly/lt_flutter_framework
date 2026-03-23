import 'package:date_utl/date_utl.dart';

import 'package:booking/booking.dart';
import 'package:booking/src/home/home_title.dart';
import 'package:booking/src/home/home_viewmodel.dart';
import 'package:booking_domain/booking_domain.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lt_uicomponent/uicomponent.dart';

const String bookingButtonKey = 'booking-button';

class HomeScreen extends StatefulWidget {
  final HomeViewmodel viewmodel;
  const HomeScreen({super.key, required this.viewmodel});

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewmodel.deleteBooking.addListener(_onResult);
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.viewmodel.deleteBooking.removeListener(_onResult);
    widget.viewmodel.deleteBooking.addListener(_onResult);
  }

  @override
  void dispose() {
    widget.viewmodel.deleteBooking.removeListener(_onResult);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        key: const ValueKey(bookingButtonKey),
        onPressed: () => context.push(Routes.search),
        label: Text(Applocalization.of(context).bookNewTrip),
        icon: const Icon(Icons.add_location_outlined),
      ),
      body: SafeArea(
        top: true,
        bottom: true,
        child: ListenableBuilder(
          listenable: widget.viewmodel.load,
          builder: (context, child) {
            if (widget.viewmodel.load.running) {
              return const Center(child: CircularProgressIndicator());
            }
            if (widget.viewmodel.load.error) {
              return ErrorIndicator(
                title: Applocalization.of(context).errorWhileLoadingHome,
                label: Applocalization.of(context).tryAgain,
                onPressed: widget.viewmodel.load.execute,
              );
            }
            return child!;
          },
          child: ListenableBuilder(
            listenable: widget.viewmodel,
            builder: (context, _) {
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: Dimens.of(context).paddingScreenVertical,
                        horizontal: Dimens.of(context).paddingScreenHorizontal,
                      ),
                      child: HomeHeader(viewmodel: widget.viewmodel),
                    ),
                  ),
                  SliverList.builder(
                    itemCount: widget.viewmodel.bookings.length,
                    itemBuilder: (context, index) {
                      return _Booking(
                        booking: widget.viewmodel.bookings[index],
                        onTap: () => context.push(
                          Routes.bookingWithId(
                            widget.viewmodel.bookings[index].id,
                          ),
                        ),
                        confirmDismiss: (_) async {
                          await widget.viewmodel.deleteBooking.execute(
                            widget.viewmodel.bookings[index].id,
                          );
                          if (widget.viewmodel.deleteBooking.completed) {
                            return true;
                          } else {
                            return false;
                          }
                        },
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _onResult() {
    if (widget.viewmodel.deleteBooking.completed) {
      widget.viewmodel.deleteBooking.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Applocalization.of(context).bookingDeleted)),
      );
    }
    if (widget.viewmodel.deleteBooking.error) {
      widget.viewmodel.deleteBooking.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Applocalization.of(context).errorWhileDeletingBooking),
        ),
      );
    }
  }
}

class _Booking extends StatelessWidget {
  final BookingSummary booking;
  final GestureTapCallback onTap;
  final ConfirmDismissCallback confirmDismiss;

  const _Booking({
    super.key,
    required this.booking,
    required this.onTap,
    required this.confirmDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(booking.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: confirmDismiss,
      background: Container(
        color: AppColors.grey1,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(right: Dimens.paddingHorizontal),
              child: Icon(Icons.delete),
            ),
          ],
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.of(context).paddingScreenHorizontal,
            vertical: Dimens.paddingVertical,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(booking.name, style: Theme.of(context).textTheme.titleLarge),
              Text(
                DateUtl.dateFormatStartEnd(
                  DateTimeRange(start: booking.startDate, end: booking.endDate),
                ),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
