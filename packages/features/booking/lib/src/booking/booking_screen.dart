import 'package:booking/booking.dart';
import 'package:booking/src/booking/booking_body.dart';
import 'package:booking/src/booking/booking_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lt_uicomponent/uicomponent.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.viewModel});

  final BookingViewModel viewModel;

  @override
  State<StatefulWidget> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.shareBooking.addListener(_listener);
  }

  @override
  void dispose() {
    widget.viewModel.shareBooking.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go(Routes.home);
      },
      child: Scaffold(
        floatingActionButton: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            return FloatingActionButton.extended(
              heroTag: null,
              key: const ValueKey('share-button'),
              onPressed: widget.viewModel.booking != null
                  ? widget.viewModel.shareBooking.execute
                  : null,
              label: Text(Applocalization.of(context).shareTrip),
              icon: const Icon(Icons.share_outlined),
            );
          },
        ),
        body: ListenableBuilder(
          listenable: Listenable.merge([
            widget.viewModel.createBooking,
            widget.viewModel.loadingBooking,
          ]),
          builder: (context, child) {
            if (widget.viewModel.createBooking.running ||
                widget.viewModel.loadingBooking.running) {
              return Center(child: CircularProgressIndicator());
            }
            if (widget.viewModel.loadingBooking.error) {
              return Center(
                child: ErrorIndicator(
                  title: Applocalization.of(context).errorWhileLoadingBooking,
                  label: Applocalization.of(context).close,
                  onPressed: () => context.go(Routes.home),
                ),
              );
            }
            return child!;
          },
          child: BookingBody(viewModel: widget.viewModel),
        ),
      ),
    );
  }

  void _listener() {
    if (widget.viewModel.shareBooking.error) {
      widget.viewModel.shareBooking.clearResult();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Applocalization.of(context).errorWhileSharing),
          action: SnackBarAction(
            label: Applocalization.of(context).tryAgain,
            onPressed: widget.viewModel.shareBooking.execute,
          ),
        ),
      );
    }
  }
}
