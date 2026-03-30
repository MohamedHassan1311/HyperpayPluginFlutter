import 'dart:convert';
import 'dart:developer' as dev;

import 'package:http/http.dart' as http;

import '../../core/constants/app_constants.dart';

class PaymentRepository {
  const PaymentRepository();

  /// Creates a HyperPay checkout session and returns the checkout ID.
  Future<String?> getCheckoutId() async {
    final url = Uri.parse(AppConstants.checkoutsUrl);
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': AppConstants.authToken,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'entityId': AppConstants.entityId,
          'amount': AppConstants.amount,
          'currency': AppConstants.currency,
          'paymentType': 'DB',
          'integrity': 'true',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        dev.log(data['id'].toString(), name: 'checkoutId');
        return data['id'] as String?;
      } else {
        dev.log(response.body, name: 'getCheckoutId.error');
        return null;
      }
    } catch (e) {
      dev.log(e.toString(), name: 'getCheckoutId.exception');
      return null;
    }
  }

  /// Returns the payment status result string for a completed checkout.
  Future<String?> getPaymentStatus(String checkoutId) async {
    final url = Uri.parse(AppConstants.paymentStatusUrl(checkoutId));
    try {
      final response = await http.get(url);
      dev.log(response.body, name: 'paymentStatus');
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data['result']?.toString();
    } catch (e) {
      dev.log(e.toString(), name: 'getPaymentStatus.exception');
      return null;
    }
  }
}
