part of 'flutter_hyperpay.dart';

/// The result state of a completed HyperPay payment operation.
enum PaymentResult {
  /// Transaction is pending server confirmation (asynchronous processing).
  sync,

  /// Transaction was approved and completed successfully.
  success,

  /// Transaction failed; inspect [PaymentResultData.errorCode] for details.
  error,

  /// The user cancelled the payment or no result was returned by the SDK.
  noResult,
}

/// Controls whether the SDK communicates with the HyperPay test or live environment.
enum PaymentMode {
  /// Live (production) environment — uses real payment credentials.
  live,

  /// Test environment — uses sandbox credentials; no real charges are made.
  test,
}
