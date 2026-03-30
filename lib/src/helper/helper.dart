import '../../flutter_hyperpay.dart';

/// Maps raw native SDK result strings to typed [PaymentResultData] objects.
class PaymentResultManger {
  /// Converts the raw [paymentResult] string returned by the native channel
  /// into a [PaymentResultData].
  ///
  /// Returns [PaymentResult.success] for `"success"`, [PaymentResult.sync]
  /// for `"SYNC"`, and [PaymentResult.noResult] for any other value.
  static PaymentResultData getPaymentResult(String paymentResult) {
    if (paymentResult == PaymentConst.success) {
      return PaymentResultData(
          errorString: '', paymentResult: PaymentResult.success);
    } else if (paymentResult == PaymentConst.sync) {
      return PaymentResultData(
          errorString: '', paymentResult: PaymentResult.sync);
    } else {
      return PaymentResultData(
          errorString: '', paymentResult: PaymentResult.noResult);
    }
  }
}
