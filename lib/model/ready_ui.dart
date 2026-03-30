import '../flutter_hyperpay.dart';

/// ReadyUI class holds all the necessary data related to the ReadyUI payment method
/// which is used in PaymentConst. It is required to provide checkoutId when initializing the class.
/// Also, we can provide brandName and themColorHexIOS as optional values.
/// setStorePaymentDetailsMode is set to false by default.
class ReadyUI {
  /// The payment type, defaults to PaymentConst.readyUi.
  final String paymentType = PaymentConst.readyUi;

  /// The HyperPay checkout ID.
  final String checkoutId;

  /// Whether to enable tokenization to store payment details.
  final bool setStorePaymentDetailsMode;

  /// List of brands to be shown in the ReadyUI (e.g., ["VISA", "MASTERCARD"]).
  final List<String> brandsName;

  /// Apple Pay Merchant ID (iOS only).
  final String merchantIdApplePayIOS;

  /// Apple Pay Country Code (iOS only).
  final String countryCodeApplePayIOS;

  /// Apple Pay Company Name (iOS only).
  final String companyNameApplePayIOS;

  /// Hexadecimal color code for the iOS ReadyUI theme.
  final String themColorHexIOS;

  /// Supported networks for Apple Pay on iOS.
  final List<String> supportedNetworksApplePayIOS;

  /// Creates a [ReadyUI] configuration.
  ///
  /// [checkoutId] and [brandsName] are required. Apple Pay fields are only
  /// used on iOS and can be omitted on Android.
  ReadyUI({
    required this.checkoutId,
    required this.brandsName,
    this.merchantIdApplePayIOS = "",
    this.countryCodeApplePayIOS = "",
    this.companyNameApplePayIOS = "",
    this.themColorHexIOS = "",
    this.setStorePaymentDetailsMode = false,
    this.supportedNetworksApplePayIOS = const ["visa", "masterCard", "mada"],
  });
}
