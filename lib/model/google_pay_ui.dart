/// Model class representing the parameters required to initiate a Google Pay payment.
class GooglePayUI {
  /// The HyperPay checkout ID for this transaction.
  final String checkoutId;

  /// The Google Pay merchant ID from the Google Pay Business Console.
  final String googlePayMerchantId;

  /// The HyperPay entity ID used as the gateway merchant ID.
  final String gatewayMerchantId;

  /// Two-letter ISO 3166 country code (e.g. "SA").
  final String countryCode;

  /// ISO 4217 currency code (e.g. "SAR").
  final String currencyCode;

  /// Transaction amount as a string (e.g. "10.00").
  final String amount;

  /// Allowed card networks. Defaults to VISA, MASTERCARD, and MADA.
  final List<String> allowedCardNetworks;

  /// Allowed card authentication methods. Defaults to PAN_ONLY and CRYPTOGRAM_3DS.
  final List<String> allowedCardAuthMethods;

  const GooglePayUI({
    required this.checkoutId,
    required this.googlePayMerchantId,
    required this.gatewayMerchantId,
    required this.countryCode,
    required this.currencyCode,
    required this.amount,
    this.allowedCardNetworks = const ["VISA", "MASTERCARD", "MADA"],
    this.allowedCardAuthMethods = const ["PAN_ONLY", "CRYPTOGRAM_3DS"],
  });
}
