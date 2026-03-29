import 'package:flutter/services.dart';
import '../../flutter_hyperpay.dart';
import '../helper/helper.dart';

/// Sends a Samsung Pay payment request to the native layer.
/// Returns [PaymentResultData] with the transaction outcome.
Future<PaymentResultData> implementSamsungPayPayment({
  required String checkoutId,
  required String merchantName,
  required String serviceId,
  required String orderNumber,
  required String amount,
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
        "type": PaymentConst.samsungPay,
        "mode": paymentMode.toString().split('.').last,
        "checkoutid": checkoutId,
        "merchantName": merchantName,
        "serviceId": serviceId,
        "orderNumber": orderNumber,
        "amount": amount,
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
