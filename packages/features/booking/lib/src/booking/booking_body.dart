import 'package:booking/src/booking/booking_header.dart';
import 'package:booking/src/booking/booking_viewmodel.dart';
import 'package:flutter/widgets.dart';

class BookingBody extends StatelessWidget {
  final BookingViewModel viewModel;

  const BookingBody({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (contex, _) {
        final booking = viewModel.booking;
        if (booking == null) return const SizedBox();
        return CustomScrollView(
          slivers: [SliverToBoxAdapter(child: BookingHeader(booking: booking))],
        );
      },
    );
  }
}
