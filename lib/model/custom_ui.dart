import '../flutter_hyperpay.dart';

/// This class is used to define a CustomUI object which is used to make payments using the PaymentConst.
/// customUi payment type. It has parameters to define the checkoutId, brandName,
/// cardNumber, holderName, month, year, cvv and enabledTokenization (optional).
class CustomUI {
  /// The payment type, defaults to PaymentConst.customUi.
  final String paymentType = PaymentConst.readyUi;

  /// The HyperPay checkout ID.
  final String checkoutId;

  /// The name of the brand (e.g., "VISA", "MASTERCARD").
  final String brandName;

  /// The credit or debit card number.
  final String cardNumber;

  /// The name of the cardholder as it appears on the card.
  final String holderName;

  /// The expiration month of the card (e.g., "12").
  final String month;

  /// The expiration year of the card (e.g., "2025").
  final String year;

  /// The 3 or 4-digit CVV/CVC security code.
  final String cvv;

  /// Whether to enable tokenization for this transaction.
  final bool enabledTokenization;

  CustomUI({
    required this.checkoutId,
    required this.brandName,
    required this.cardNumber,
    required this.holderName,
    required this.month,
    required this.year,
    required this.cvv,
    this.enabledTokenization = false,
  });
}
