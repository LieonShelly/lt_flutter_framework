import 'package:equatable/equatable.dart';

sealed class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

final class LoadedCheckoutDataEvent extends CheckoutEvent {}

final class AddPwpItemEvent extends CheckoutEvent {
  final String productId;

  const AddPwpItemEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

final class SelectVoucherEvent extends CheckoutEvent {
  final bool isMutuallyExclusive;

  const SelectVoucherEvent(this.isMutuallyExclusive);

  @override
  List<Object?> get props => [isMutuallyExclusive];
}
