/// Model class representing the parameters required to initiate a Samsung Pay payment.
class SamsungPayUI {
  /// The HyperPay checkout ID for this transaction.
  final String checkoutId;

  /// The merchant's display name shown in the Samsung Pay sheet.
  final String merchantName;

  /// The Samsung Pay service ID registered in Samsung Pay Developers portal.
  final String serviceId;

  /// Merchant-assigned order number for reference.
  final String orderNumber;

  /// Transaction amount as a string (e.g. "10.00").
  final String amount;

  const SamsungPayUI({
    required this.checkoutId,
    required this.merchantName,
    required this.serviceId,
    required this.orderNumber,
    required this.amount,
  });
}
