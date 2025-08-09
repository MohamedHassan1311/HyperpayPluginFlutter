import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:hyperpay_plugin/flutter_hyperpay.dart';
import 'dart:convert';

import 'package:hyperpay_plugin/model/custom_ui.dart';
import 'package:hyperpay_plugin/model/custom_ui_stc.dart';
import 'package:hyperpay_plugin/model/ready_ui.dart';

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
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  @override
  void initState() {

    flutterHyperPay = FlutterHyperPay(
      shopperResultUrl: InAppPaymentSetting.shopperResultUrl,
      paymentMode: PaymentMode.test,
      lang: InAppPaymentSetting.getLang(),
    );

    super.initState();
  }

  String? _resultText;
  String? _checkoutid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _resultText ?? "",
              style: const TextStyle(fontSize: 20, color: Colors.black),
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              "pay with ready ui".toUpperCase(),
              style: const TextStyle(fontSize: 20, color: Colors.black),
            ),
            InkWell(
                onTap: () async {
                  _checkoutid = await Network.getCheckOut();
                  if (_checkoutid != null) {
                    /// Brands Names [ VISA , MASTER , MADA , STC_PAY , APPLEPAY]
                    payRequestNowReadyUI(brandsName: [
                      "VISA",
                      "MASTER",
                      "MADA",
                      "PAYPAL",
                      "STC_PAY",
                      "APPLEPAY"
                    ], checkoutId: _checkoutid!);
                  }
                },
                child: const Text(
                  "[VISA,MASTER,MADA,STC_PAY,APPLEPAY]",
                  style: TextStyle(fontSize: 20),
                )),
            const Divider(),
            Text(
              "pay with custom ui".toUpperCase(),
              style: const TextStyle(fontSize: 20, color: Colors.black),
            ),
            InkWell(
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => const CheckoutView(),
                    ),
                  );
                },
                child: const Text(
                  "CUSTOM_UI",
                  style: TextStyle(fontSize: 20),
                )),
            const Divider(),
            Text(
              "pay with custom ui stc".toUpperCase(),
              style: const TextStyle(fontSize: 20, color: Colors.red),
            ),
            InkWell(
                onTap: () async {
                  _checkoutid = await Network.getCheckOut();
                  if (_checkoutid != null) {
                    payRequestNowCustomUiSTCPAY(
                        checkoutId: _checkoutid!, phoneNumber: "5055555555");
                  }
                },
                child: const Text(
                  "STC_PAY",
                  style: TextStyle(fontSize: 20),
                )),
            if (Platform.isIOS)
              GestureDetector(
                onTap: () async {
                  _checkoutid = await Network.getCheckOut();
                  payWithApplePAY(checkoutId: _checkoutid!);
                },
                child: Container(
                  width: 250,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.black, // Apple Pay button is usually black
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons
                            .apple, // Apple icon (you can use custom SVG for better accuracy)
                        color: Colors.white,
                        size: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Pay with Apple Pay',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  /// URL TO GET CHECKOUT ID FOR TEST
  /// http://dev.hyperpay.com/hyperpay-demo/getcheckoutid.php

  payRequestNowReadyUI(
      {required List<String> brandsName, required String checkoutId}) async {
    PaymentResultData paymentResultData;
    paymentResultData = await flutterHyperPay.readyUICards(
      readyUI: ReadyUI(
          brandsName: brandsName,
          checkoutId: checkoutId,
          merchantIdApplePayIOS: InAppPaymentSetting.merchantId,
          countryCodeApplePayIOS: InAppPaymentSetting.countryCode,
          companyNameApplePayIOS: "Test Co",
          themColorHexIOS: "#000000", // FOR IOS ONLY
          setStorePaymentDetailsMode:
              false // store payment details for future use
          ),
    );

    print(paymentResultData.paymentResult.name);
    if (paymentResultData.paymentResult == PaymentResult.success ||
        paymentResultData.paymentResult == PaymentResult.sync) {
      Network.getpaymentstatus(_checkoutid);
    }
  }

  payRequestNowCustomUiSTCPAY(
      {required String phoneNumber, required String checkoutId}) async {
    PaymentResultData paymentResultData;

    paymentResultData = await flutterHyperPay.customUISTC(
      customUISTC:
          CustomUISTC(checkoutId: checkoutId, phoneNumber: phoneNumber),
    );

    if (paymentResultData.paymentResult == PaymentResult.success ||
        paymentResultData.paymentResult == PaymentResult.sync) {
      Network.getpaymentstatus(_checkoutid);
      // do something
    } else {
      Network.getpaymentstatus(_checkoutid);
    }
  }

  payWithApplePAY({required String checkoutId}) async {
    PaymentResultData paymentResultData;

    paymentResultData = await flutterHyperPay.readyUICards(
      readyUI: ReadyUI(
        checkoutId: checkoutId,
        merchantIdApplePayIOS: InAppPaymentSetting.merchantId,
        countryCodeApplePayIOS: InAppPaymentSetting.countryCode,
        companyNameApplePayIOS: "Test Co",
        themColorHexIOS: "#000000", brandsName: ["APPLEPAY"], // FOR IOS ONLY
      ),
    );

    if (paymentResultData.paymentResult == PaymentResult.success ||
        paymentResultData.paymentResult == PaymentResult.sync) {
      Network.getpaymentstatus(_checkoutid);
      // do something
    } else {
      Network.getpaymentstatus(_checkoutid);
    }
  }
}

class InAppPaymentSetting {
  static const String shopperResultUrl = "com.testpayment.payment";
  static const String merchantId = "marchant.com.example.hyperpay";
  static const String countryCode = "SA";
  static getLang() {
    if (Platform.isIOS) {
      return "en"; // ar
    } else {
      return "en_US"; // ar_AR
    }
  }
}
