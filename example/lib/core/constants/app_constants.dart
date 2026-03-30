import 'dart:io';

class AppConstants {
  AppConstants._();

  // ── Shopper / merchant identifiers ────────────────────────────────────────
  static const String shopperResultUrl = 'com.testpayment.payment';
  static const String merchantId = 'marchant.com.example.hyperpay';
  static const String countryCode = 'SA';

  // ── API credentials (test environment) ───────────────────────────────────
  static const String _baseUrl = 'https://eu-test.oppwa.com/v1';
  static const String entityId = '8a8294174d0595bb014d05d829cb01cd';
  static const String authToken =
      'Bearer OGE4Mjk0MTc0ZDA1OTViYjAxNGQwNWQ4MjllNzAxZDF8OVRuSlBjMm45aA==';

  // ── Payment defaults ──────────────────────────────────────────────────────
  static const String amount = '92.00';
  static const String currency = 'SAR';

  // ── Endpoints ─────────────────────────────────────────────────────────────
  static String get checkoutsUrl => '$_baseUrl/checkouts';
  static String paymentStatusUrl(String checkoutId) =>
      '$_baseUrl/checkouts/$checkoutId/payment';

  // ── Localisation ──────────────────────────────────────────────────────────
  static String get lang => Platform.isIOS ? 'en' : 'en_US';
}
