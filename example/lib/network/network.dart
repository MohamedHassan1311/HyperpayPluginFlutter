// This file is kept for backward compatibility.
// Use PaymentRepository from data/repositories/payment_repository.dart instead.
@Deprecated('Use PaymentRepository instead')
library;

import 'dart:convert';
import 'dart:developer' as dev;

import 'package:http/http.dart' as http;

@Deprecated('Use PaymentRepository instead')
class Network {
  static Future<String?> getCheckOut() async {
    final url = Uri.parse('https://eu-test.oppwa.com/v1/checkouts');
    final response = await http.post(
      url,
      headers: {
        'Authorization':
            'Bearer OGE4Mjk0MTc0ZDA1OTViYjAxNGQwNWQ4MjllNzAxZDF8OVRuSlBjMm45aA==',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'entityId': '8a8294174d0595bb014d05d829cb01cd',
        'amount': '92.00',
        'currency': 'SAR',
        'paymentType': 'DB',
        'integrity': 'true',
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      dev.log(data['id'].toString(), name: 'checkoutId');
      return data['id'] as String?;
    } else {
      dev.log(response.body, name: 'Network.getCheckOut.error');
      return null;
    }
  }

  static Future<String?> getpaymentstatus(dynamic checkoutid) async {
    final url =
        Uri.parse('https://eu-test.oppwa.com/v1/checkouts/$checkoutid/payment');
    final response = await http.get(url);
    dev.log(response.body, name: 'paymentStatus');
    final data = json.decode(response.body) as Map<String, dynamic>;
    return data['result']?.toString();
  }
}
