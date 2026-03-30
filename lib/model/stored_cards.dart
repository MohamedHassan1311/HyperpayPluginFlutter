import '../flutter_hyperpay.dart';

/// This is the class for StoredCards. It has fields to store payment type,
/// checkoutId, tokenId, brandName and cvv. PaymentType is set to the PaymentConst.readyUi,
/// checkoutId and tokenId are required fields and brandName and cvv are optional fields.
class StoredCards {
  /// The payment type, defaults to PaymentConst.storedCards.
  final String paymentType = PaymentConst.storedCards;

  /// The HyperPay checkout ID.
  final String checkoutId;

  /// The token ID representing a previously stored payment card.
  final String tokenId;

  /// The brand name of the stored card (e.g., "VISA").
  final String? brandName;

  /// The 3 or 4-digit CVV code for the stored card.
  final String cvv;

  /// Creates a [StoredCards] payment request.
  ///
  /// [tokenId] is the token returned by a previous HyperPay transaction when
  /// tokenization was enabled. [cvv] is always required for security.
  StoredCards({
    required this.checkoutId,
    required this.tokenId,
    required this.cvv,
    this.brandName,
  });
}
