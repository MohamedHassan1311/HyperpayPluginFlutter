import 'package:flutter/services.dart';
import '../../flutter_hyperpay.dart';
import '../helper/helper.dart';

/// This function is used to implement payment using stored cards.
/// The [brand] should be provided for the payment.
/// The [checkoutId] should be provided for the payment.
/// The [tokenId] should be provided for the payment.
/// The [cvv] should be provided for the payment.
/// The [channelName] should be provided for the payment.
/// The [shopperResultUrl] should be provided for the payment.
/// The [paymentMode] should be provided for the payment.
/// The [lang] should be provided for the payment.
/// It will return a [Future<PaymentResultData>] object that contains the payment result.
Future<PaymentResultData> implementPaymentStoredCards({
  required String? brand,
  required String checkoutId,
  required String tokenId,
  required String cvv,
  required String channelName,
  required String shopperResultUrl,
  required PaymentMode paymentMode,
  required String lang,
}) async {
  String transactionStatus;
  var platform = MethodChannel(channelName);
  try {
    final String? result = await platform.invokeMethod(
      PaymentConst.methodCall,
      getPaymentWithCards(
          tokenId: tokenId,
          brand: brand,
          cvv: cvv,
          checkoutId: checkoutId,
          channelName: channelName,
          shopperResultUrl: shopperResultUrl,
          paymentMode: paymentMode,
          lang: lang),
    );
    transactionStatus = '$result';
    return PaymentResultManger.getPaymentResult(transactionStatus);
  } on PlatformException catch (e) {
    transactionStatus = "${e.message}";
    return PaymentResultData(
        errorString: e.message, errorCode: e.code, paymentResult: PaymentResult.error);
  }
}

/// Builds the method-channel argument map for a stored-card payment.
///
/// Returns a [Map] whose keys match the parameter names expected by the
/// native HyperPay SDK plugin on both Android and iOS.
Map<String, String?> getPaymentWithCards({
  required String? brand,
  required String checkoutId,
  required String tokenId,
  required String cvv,
  required String channelName,
  required String shopperResultUrl,
  required PaymentMode paymentMode,
  required String lang,
}) {
  return {
    "type": PaymentConst.storedCards,
    "mode": paymentMode.toString().split('.').last,
    "checkoutid": checkoutId,
    "brand": brand,
    "lang": lang,
    "ShopperResultUrl": shopperResultUrl,
    "TokenID": tokenId,
    "cvv": cvv,
  };
}
