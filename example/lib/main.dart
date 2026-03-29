import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hyperpay_payment_sdk/flutter_hyperpay.dart';
import 'package:hyperpay_payment_sdk/model/custom_ui_stc.dart';
import 'package:hyperpay_payment_sdk/model/google_pay_ui.dart';
import 'package:hyperpay_payment_sdk/model/ready_ui.dart';
import 'package:hyperpay_payment_sdk/model/samsung_pay_ui.dart';

import 'checkout_view.dart';
import 'network/network.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HyperPay Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'HyperPay Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FlutterHyperPay flutterHyperPay;
  String? _resultText;
  String? _checkoutid;

  @override
  void initState() {
    flutterHyperPay = FlutterHyperPay(
      shopperResultUrl: InAppPaymentSetting.shopperResultUrl,
      paymentMode: PaymentMode.test,
      lang: InAppPaymentSetting.getLang(),
    );
    super.initState();
  }

  void _showResult(String text) {
    setState(() => _resultText = text);
  }

  void _handleResult(PaymentResultData result) {
    switch (result.paymentResult) {
      case PaymentResult.success:
        _showResult("✅ Payment successful!");
        Network.getpaymentstatus(_checkoutid);
        break;
      case PaymentResult.sync:
        _showResult("⏳ Payment processing (SYNC)...");
        Network.getpaymentstatus(_checkoutid);
        break;
      case PaymentResult.error:
        _showResult("❌ Error [${result.errorCode}]: ${result.errorString}");
        break;
      case PaymentResult.noResult:
        _showResult("⏸ Payment cancelled.");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("HyperPay Demo")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_resultText != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  _resultText!,
                  style: const TextStyle(fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),

            // ── Ready UI ──────────────────────────────────────────────
            _sectionTitle("Ready UI"),
            _demoButton(
              label: "Pay [VISA, MASTER, MADA, STC_PAY, APPLEPAY]",
              onTap: () async {
                _checkoutid = await Network.getCheckOut();
                print("checkoutid: $_checkoutid");
                if (_checkoutid != null) {
                  _payReadyUI(brandsName: [
                    "VISA",
                    "MASTER",
                    "MADA",
                    "STC_PAY",
                    "APPLEPAY"
                  ], checkoutId: _checkoutid!);
                }
              },
            ),

            // ── Custom UI ─────────────────────────────────────────────
            _sectionTitle("Custom UI"),
            _demoButton(
              label: "Pay with Card Form",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CheckoutView()),
              ),
            ),

            // ── STC Pay ───────────────────────────────────────────────
            _sectionTitle("STC Pay"),
            _demoButton(
              label: "Pay with STC Pay",
              color: Colors.red.shade600,
              onTap: () async {
                _checkoutid = await Network.getCheckOut();
                if (_checkoutid != null) {
                  _paySTCPay(
                      checkoutId: _checkoutid!, phoneNumber: "5055555555");
                }
              },
            ),

            // ── Google Pay (Android only) ─────────────────────────────
            if (Platform.isAndroid) ...[
              _sectionTitle("Google Pay (Android)"),
              _demoButton(
                label: "Pay with Google Pay",
                color: Colors.green.shade700,
                onTap: () async {
                  _checkoutid = await Network.getCheckOut();
                  if (_checkoutid != null) {
                    _payGooglePay(checkoutId: _checkoutid!);
                  }
                },
              ),
            ],

            // ── Samsung Pay (Android only) ────────────────────────────
            if (Platform.isAndroid) ...[
              _sectionTitle("Samsung Pay (Android)"),
              _demoButton(
                label: "Pay with Samsung Pay",
                color: Colors.indigo.shade700,
                onTap: () async {
                  _checkoutid = await Network.getCheckOut();
                  if (_checkoutid != null) {
                    _paySamsungPay(checkoutId: _checkoutid!);
                  }
                },
              ),
            ],

            // ── BIN Lookup ────────────────────────────────────────────
            _sectionTitle("BIN Lookup / Card Brand Detection"),
            _demoButton(
              label: "Detect Card Brand",
              color: Colors.orange.shade700,
              onTap: () async {
                _checkoutid = await Network.getCheckOut();
                if (_checkoutid != null) {
                  _lookupBrands(checkoutId: _checkoutid!);
                }
              },
            ),

            // ── Apple Pay (iOS only) ──────────────────────────────────
            if (Platform.isIOS) ...[
              _sectionTitle("Apple Pay (iOS)"),
              GestureDetector(
                onTap: () async {
                  _checkoutid = await Network.getCheckOut();
                  if (_checkoutid != null) {
                    _payApplePay(checkoutId: _checkoutid!);
                  }
                },
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.apple, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text("Pay with Apple Pay",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Payment methods ────────────────────────────────────────────────────

  Future<void> _payReadyUI(
      {required List<String> brandsName, required String checkoutId}) async {
    final result = await flutterHyperPay.readyUICards(
      readyUI: ReadyUI(
        brandsName: brandsName,
        checkoutId: checkoutId,
        merchantIdApplePayIOS: InAppPaymentSetting.merchantId,
        countryCodeApplePayIOS: InAppPaymentSetting.countryCode,
        companyNameApplePayIOS: "Test Co",
        themColorHexIOS: "#000000",
        setStorePaymentDetailsMode: false,
        supportedNetworksApplePayIOS: ["visa", "masterCard", "mada"],
      ),
    );
    _handleResult(result);
  }

  Future<void> _paySTCPay(
      {required String checkoutId, required String phoneNumber}) async {
    final result = await flutterHyperPay.customUISTC(
      customUISTC: CustomUISTC(
          checkoutId: checkoutId, phoneNumber: phoneNumber),
    );
    _handleResult(result);
  }

  Future<void> _payGooglePay({required String checkoutId}) async {
    final result = await flutterHyperPay.googlePayUI(
      googlePayUI: GooglePayUI(
        checkoutId: checkoutId,
        googlePayMerchantId: "YOUR_GOOGLE_PAY_MERCHANT_ID",
        gatewayMerchantId: "YOUR_HYPERPAY_ENTITY_ID",
        countryCode: "SA",
        currencyCode: "SAR",
        amount: "10.00",
        allowedCardNetworks: ["VISA", "MASTERCARD", "MADA"],
        allowedCardAuthMethods: ["PAN_ONLY", "CRYPTOGRAM_3DS"],
      ),
    );
    _handleResult(result);
  }

  Future<void> _paySamsungPay({required String checkoutId}) async {
    final result = await flutterHyperPay.samsungPayUI(
      samsungPayUI: SamsungPayUI(
        checkoutId: checkoutId,
        merchantName: "Test Store",
        serviceId: "YOUR_SAMSUNG_PAY_SERVICE_ID",
        orderNumber: "ORDER_001",
        amount: "10.00",
      ),
    );
    _handleResult(result);
  }

  Future<void> _lookupBrands({required String checkoutId}) async {
    final brands = await flutterHyperPay.requestBrands(
        checkoutId: checkoutId);
    if (brands.isEmpty) {
      _showResult("🔍 No brand detected");
    } else {
      _showResult("🔍 Detected brands: ${brands.join(', ')}");
    }
  }

  Future<void> _payApplePay({required String checkoutId}) async {
    final result = await flutterHyperPay.readyUICards(
      readyUI: ReadyUI(
        checkoutId: checkoutId,
        merchantIdApplePayIOS: InAppPaymentSetting.merchantId,
        countryCodeApplePayIOS: InAppPaymentSetting.countryCode,
        companyNameApplePayIOS: "Test Co",
        themColorHexIOS: "#000000",
        brandsName: ["APPLEPAY"],
        supportedNetworksApplePayIOS: ["visa", "masterCard", "mada"],
      ),
    );
    _handleResult(result);
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 6),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
              letterSpacing: 0.5),
        ),
      );

  Widget _demoButton(
      {required String label,
      required VoidCallback onTap,
      Color? color}) =>
      ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.blue.shade700,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 15)),
      );
}

class InAppPaymentSetting {
  static const String shopperResultUrl = "com.testpayment.payment";
  static const String merchantId = "marchant.com.example.hyperpay";
  static const String countryCode = "SA";

  static String getLang() {
    if (Platform.isIOS) {
      return "en"; // use "ar" for Arabic
    } else {
      return "en_US"; // use "ar_AR" for Arabic
    }
  }
}
