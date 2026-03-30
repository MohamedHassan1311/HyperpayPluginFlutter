part of 'flutter_hyperpay.dart';

/// Constants used as payment type identifiers and status codes when
/// communicating with the native HyperPay SDK over the method channel.
class PaymentConst {
  /// Payment type identifier for Apple Pay.
  static const String applePay = "APPLEPAY";

  /// Payment type identifier for the HyperPay Ready UI flow.
  static const String readyUi = "ReadyUI";

  /// Payment type identifier for the Custom UI card flow.
  static const String customUi = "CustomUI";

  /// Payment type identifier for the Custom UI STC Pay flow.
  static const String customUiSTC = "CustomUISTC";

  /// Payment type identifier for paying with a stored/tokenised card.
  static const String storedCards = "StoredCards";

  /// The method channel method name used for all HyperPay SDK calls.
  static const String methodCall = "gethyperpayresponse";

  /// Native SDK result string indicating a successful transaction.
  static const String success = "success";

  /// Native SDK result string indicating a failed transaction.
  static const String error = "error";

  /// Native SDK result string indicating a synchronous (pending) transaction.
  static const String sync = "SYNC";

  /// Payment type identifier for Google Pay.
  static const String googlePay = "GooglePayUI";

  /// Payment type identifier for Samsung Pay.
  static const String samsungPay = "SamsungPayUI";
}

/// Brand name constants accepted by the HyperPay SDK.
///
/// Use these values in [ReadyUI.brandsName], [CustomUI.brandName],
/// or wherever a brand string is required.
class PaymentBrands {
  /// Saudi MADA debit network brand identifier.
  static const String mada = "MADA";

  /// Apple Pay brand identifier.
  static const String applePay = "APPLEPAY";

  /// Generic credit card brand identifier.
  static const String credit = "credit";

  /// STC Pay brand identifier.
  static const String stcPay = "STC_PAY";

  /// Mastercard brand identifier.
  static const String masterCard = "MASTERCARD";

  /// Visa brand identifier.
  static const String visa = "VISA";

  /// Google Pay brand identifier.
  static const String googlePay = "GOOGLEPAY";

  /// Samsung Pay brand identifier.
  static const String samsungPay = "SAMSUNG_PAY";
}

/// Holds the outcome of a HyperPay payment operation.
///
/// Inspect [paymentResult] to branch on success, sync, error, or cancellation.
/// When [paymentResult] is [PaymentResult.error], [errorCode] and [errorString]
/// contain the native SDK error details.
class PaymentResultData {
  /// Human-readable error message from the native SDK, or empty string on success.
  final String? errorString;

  /// Machine-readable error code from the native SDK (e.g. `"PLATFORM_NOT_SUPPORTED"`).
  /// `null` when the transaction is not in an error state.
  final String? errorCode;

  /// The overall outcome of the payment transaction.
  final PaymentResult paymentResult;

  /// Creates a [PaymentResultData] with the given [paymentResult].
  ///
  /// Provide [errorString] and [errorCode] when [paymentResult] is
  /// [PaymentResult.error].
  PaymentResultData({
    required this.errorString,
    this.errorCode,
    required this.paymentResult,
  });
}

/// Language locale constants for the HyperPay payment UI.
///
/// Pass the appropriate value to [FlutterHyperPay.lang] based on the
/// target platform and desired locale.
class PaymentLang {
  /// Arabic locale for iOS.
  static const String iosARLang = "ar";

  /// English locale for iOS.
  static const String iosENLang = "en";

  /// English locale for Android.
  static const String androidENLang = "en_US";

  /// Arabic locale for Android.
  static const String androidARLang = "ar_AR";
}
