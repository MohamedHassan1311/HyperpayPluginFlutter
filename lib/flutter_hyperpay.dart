import 'dart:async';

import 'model/custom_ui.dart';
import 'model/custom_ui_stc.dart';
import 'model/google_pay_ui.dart';
import 'model/ready_ui.dart';
import 'model/samsung_pay_ui.dart';
import 'model/stored_cards.dart';
import 'src/brands/method_channel_brands.dart';
import 'src/custom_ui/method_channel_custom_ui.dart';
import 'src/custom_ui/method_channel_custom_ui_stc.dart';
import 'src/google_pay/method_channel_google_pay.dart';
import 'src/ready_ui/method_channel_ready_ui.dart';
import 'src/samsung_pay/method_channel_samsung_pay.dart';
import 'src/store_cards/method_channel_store_cards.dart';

part 'hyper_pay_const.dart';

part 'enum.dart';

/// Main entry point for the HyperPay Payment SDK.
///
/// Create one instance per screen/session and call the appropriate method
/// depending on the payment flow you want to use (Ready UI, Custom UI,
/// Google Pay, Samsung Pay, Apple Pay, or stored cards).
///
/// ```dart
/// final hyperPay = FlutterHyperPay(
///   shopperResultUrl: 'com.example.app',
///   paymentMode: PaymentMode.test,
///   lang: 'en',
/// );
/// ```
class FlutterHyperPay {
  /// The name of the platform channel used for communication with native code.
  final String channelName = "com.hyperpay.sdk/channel";

  /// The URL used by the payment gateway to redirect the user back to the app after a payment.
  final String shopperResultUrl;

  /// The language used for the payment interface (e.g., "en", "ar").
  final String lang;

  /// The payment mode to be used: [PaymentMode.test] or [PaymentMode.live].
  final PaymentMode paymentMode;

  /// Creates a [FlutterHyperPay] instance.
  ///
  /// [shopperResultUrl] must match the custom URL scheme registered in your
  /// app's manifest/Info.plist so the SDK can redirect back after payment.
  /// [paymentMode] controls whether test or live credentials are used.
  /// [lang] sets the UI language — use [PaymentLang] constants for valid values.
  FlutterHyperPay({
    required this.shopperResultUrl,
    required this.paymentMode,
    required this.lang,
  });

  /// This async function takes a ReadyUI object as input and returns a Future object of type PaymentResultData.
  /// It implements a payment operation by passing the Brand name, Checkout ID, Shopper Result URL,
  /// Payment Channel name, Payment mode, Language, Theme color in HEX (iOS),
  /// and a flag to set the store payment details mode.
  /// The function waits for the payment operation to complete and returns the resulting PaymentResultData.
  Future<PaymentResultData> readyUICards({required ReadyUI readyUI}) async {
    return await implementPayment(
      brands: readyUI.brandsName,
      checkoutId: readyUI.checkoutId,
      shopperResultUrl: shopperResultUrl,
      channelName: channelName,
      paymentMode: paymentMode,
      merchantId: readyUI.merchantIdApplePayIOS,
      countryCode: readyUI.countryCodeApplePayIOS,
      companyName: readyUI.companyNameApplePayIOS,
      lang: lang,
      themColorHexIOS: readyUI.themColorHexIOS,
      setStorePaymentDetailsMode: readyUI.setStorePaymentDetailsMode,
      supportedNetworks: readyUI.supportedNetworksApplePayIOS,
    );
  }

  /// This method is used for making custom UI payments with cards.
  /// It takes in the required CustomUI input and returns a PaymentResultData object.
  Future<PaymentResultData> customUICards({required CustomUI customUI}) async {
    return await implementPaymentCustomUI(
      brand: customUI.brandName,
      checkoutId: customUI.checkoutId,
      shopperResultUrl: shopperResultUrl,
      channelName: channelName,
      paymentMode: paymentMode,
      cardNumber: customUI.cardNumber,
      holderName: customUI.holderName,
      month: customUI.month,
      year: customUI.year,
      cvv: customUI.cvv,
      lang: lang,
      enabledTokenization: customUI.enabledTokenization,
    );
  }

  /// This function is used to do payment using custom UI. It takes "CustomUI" as an argument,
  /// which consists of the brand name, checkout id, card number, holder name, month, year and cvv.
  /// The function returns a Future of PaymentResultData.
  Future<PaymentResultData> customUISTC(
      {required CustomUISTC customUISTC}) async {
    return await implementPaymentCustomUISTC(
      checkoutId: customUISTC.checkoutId,
      shopperResultUrl: shopperResultUrl,
      channelName: channelName,
      paymentMode: paymentMode,
      lang: lang,
      phoneNumber: customUISTC.phoneNumber,
    );
  }

  /// This function allows the user to make payments using their stored cards.
  /// It accepts an argument of type StoredCards and makes a call to the implementPaymentStoredCards
  /// function with the values required for the payment.

  Future<PaymentResultData> payWithSoredCards(
      {required StoredCards storedCards}) async {
    return await implementPaymentStoredCards(
      brand: storedCards.brandName,
      checkoutId: storedCards.checkoutId,
      tokenId: storedCards.tokenId,
      cvv: storedCards.cvv,
      shopperResultUrl: shopperResultUrl,
      channelName: channelName,
      paymentMode: paymentMode,
      lang: lang,
    );
  }

  /// Initiates a Google Pay payment on Android.
  ///
  /// Returns [PaymentResultData] with [PaymentResult.success] or [PaymentResult.sync]
  /// on completion, [PaymentResult.noResult] if cancelled, and [PaymentResult.error]
  /// if Google Pay is unavailable or the transaction fails.
  ///
  /// **Android only.** On iOS, returns [PaymentResult.error] with errorCode
  /// "PLATFORM_NOT_SUPPORTED".
  Future<PaymentResultData> googlePayUI(
      {required GooglePayUI googlePayUI}) async {
    return await implementGooglePayPayment(
      checkoutId: googlePayUI.checkoutId,
      googlePayMerchantId: googlePayUI.googlePayMerchantId,
      gatewayMerchantId: googlePayUI.gatewayMerchantId,
      countryCode: googlePayUI.countryCode,
      currencyCode: googlePayUI.currencyCode,
      amount: googlePayUI.amount,
      allowedCardNetworks: googlePayUI.allowedCardNetworks,
      allowedCardAuthMethods: googlePayUI.allowedCardAuthMethods,
      channelName: channelName,
      shopperResultUrl: shopperResultUrl,
      paymentMode: paymentMode,
      lang: lang,
    );
  }

  /// Initiates a Samsung Pay payment on Android.
  ///
  /// Returns [PaymentResultData] with [PaymentResult.success] or [PaymentResult.sync]
  /// on completion, [PaymentResult.noResult] if cancelled, and [PaymentResult.error]
  /// if Samsung Pay is unavailable or the transaction fails.
  ///
  /// **Android only.** On iOS, returns [PaymentResult.error] with errorCode
  /// "PLATFORM_NOT_SUPPORTED".
  Future<PaymentResultData> samsungPayUI(
      {required SamsungPayUI samsungPayUI}) async {
    return await implementSamsungPayPayment(
      checkoutId: samsungPayUI.checkoutId,
      merchantName: samsungPayUI.merchantName,
      serviceId: samsungPayUI.serviceId,
      orderNumber: samsungPayUI.orderNumber,
      amount: samsungPayUI.amount,
      channelName: channelName,
      shopperResultUrl: shopperResultUrl,
      paymentMode: paymentMode,
      lang: lang,
    );
  }

  /// Requests card brand detection for a given checkout ID (BIN lookup).
  ///
  /// Returns a list of detected brand names (e.g. ["VISA"], ["MADA"]).
  /// Returns an empty list if no brand is detected for the given prefix.
  /// Does NOT require an active payment session.
  ///
  /// [checkoutId] is required by the HyperPay SDK for brand validation context.
  Future<List<String>> requestBrands({required String checkoutId}) async {
    return await implementRequestBrands(
      checkoutId: checkoutId,
      channelName: channelName,
      shopperResultUrl: shopperResultUrl,
      paymentMode: paymentMode,
      lang: lang,
    );
  }
}
