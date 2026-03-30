

import 'package:hyperpay_payment_sdk/flutter_hyperpay.dart';

/// A handy util to turn mode enums into their corresponding
/// HyperPay string representation.
extension PaymentModeExtension on PaymentMode {
  String get string {
    switch (this) {
      case PaymentMode.live:
        return 'LIVE';
      case PaymentMode.test:
        return 'TEST';
      default:
        return '';
    }
  }
}
