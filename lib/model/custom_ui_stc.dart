import '../flutter_hyperpay.dart';

/// Class CustomUISTC is used to store the payment type,
/// checkout ID, and phone number for custom UI payment.
class CustomUISTC {
  /// The payment type, defaults to PaymentConst.customUiSTC.
  final String paymentType = PaymentConst.customUiSTC;

  /// The HyperPay checkout ID.
  final String checkoutId;

  /// The shopper's phone number for STC Pay verification.
  final String phoneNumber;

  CustomUISTC({
    required this.checkoutId,
    required this.phoneNumber,
  });
}
