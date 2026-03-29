import 'package:flutter/services.dart';
import '../../flutter_hyperpay.dart';
import '../helper/helper.dart';

/// Sends a Google Pay payment request to the native layer.
/// Returns [PaymentResultData] with the transaction outcome.
Future<PaymentResultData> implementGooglePayPayment({
  required String checkoutId,
  required String googlePayMerchantId,
  required String gatewayMerchantId,
  required String countryCode,
  required String currencyCode,
  required String amount,
  required List<String> allowedCardNetworks,
  required List<String> allowedCardAuthMethods,
  required String channelName,
  required String shopperResultUrl,
  required PaymentMode paymentMode,
  required String lang,
}) async {
  var platform = MethodChannel(channelName);
  try {
    final String? result = await platform.invokeMethod(
      PaymentConst.methodCall,
      {
        "type": PaymentConst.googlePay,
        "mode": paymentMode.toString().split('.').last,
        "checkoutid": checkoutId,
        "googlePayMerchantId": googlePayMerchantId,
        "gatewayMerchantId": gatewayMerchantId,
        "countryCode": countryCode,
        "currencyCode": currencyCode,
        "amount": amount,
        "allowedCardNetworks": allowedCardNetworks,
        "allowedCardAuthMethods": allowedCardAuthMethods,
        "ShopperResultUrl": shopperResultUrl,
        "lang": lang,
      },
    );
    return PaymentResultManger.getPaymentResult('$result');
  } on PlatformException catch (e) {
    return PaymentResultData(
        errorString: e.message, errorCode: e.code, paymentResult: PaymentResult.error);
  }
}
