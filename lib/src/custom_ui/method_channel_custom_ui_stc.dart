import 'package:flutter/services.dart';
import '../../flutter_hyperpay.dart';
import '../helper/helper.dart';

/// implementPaymentCustomUISTC is a method used to make online payments.
/// It requires the paymentMode, checkoutId, channelName, shopperResultUrl,
/// phoneNumber and lang to be passed as arguments for successful implementation.
/// It returns a PaymentResultData object with the paymentResult and errorString.
Future<PaymentResultData> implementPaymentCustomUISTC({
  required PaymentMode paymentMode,
  required String checkoutId,
  required String channelName,
  required String shopperResultUrl,
  required String phoneNumber,
  required String lang,
}) async {
  String transactionStatus;
  var platform = MethodChannel(channelName);
  try {
    final String? result = await platform.invokeMethod(
      PaymentConst.methodCall,
      getCustomUiSTCModelCards(
          checkoutId: checkoutId,
          shopperResultUrl: shopperResultUrl,
          paymentMode: paymentMode,
          phoneNumber: phoneNumber,
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

/// Builds the method-channel argument map for an STC Pay payment.
///
/// Returns a [Map] whose keys match the parameter names expected by the
/// native HyperPay SDK plugin on both Android and iOS.
Map<String, String?> getCustomUiSTCModelCards({
  required PaymentMode paymentMode,
  required String phoneNumber,
  required String checkoutId,
  required String lang,
  required String shopperResultUrl,
}) {
  return {
    "type": PaymentConst.customUiSTC,
    "mode": paymentMode.toString().split('.').last,
    "checkoutid": checkoutId,
    "phone_number": phoneNumber,
    "lang": lang,
    "ShopperResultUrl": shopperResultUrl,
  };
}
