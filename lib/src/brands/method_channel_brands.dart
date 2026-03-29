import 'package:flutter/services.dart';
import '../../flutter_hyperpay.dart';

/// Requests card brand detection from the native layer (BIN lookup).
/// Returns a list of detected brand strings (e.g. ["VISA"]).
/// Returns an empty list if no brands are detected or if the call fails gracefully.
Future<List<String>> implementRequestBrands({
  required String checkoutId,
  required String channelName,
  required String shopperResultUrl,
  required PaymentMode paymentMode,
  required String lang,
}) async {
  var platform = MethodChannel(channelName);
  try {
    final List<dynamic>? result = await platform.invokeMethod(
      PaymentConst.methodCall,
      {
        "type": "RequestBrands",
        "checkoutid": checkoutId,
        "mode": paymentMode.toString().split('.').last,
        "ShopperResultUrl": shopperResultUrl,
        "lang": lang,
      },
    );
    return result?.cast<String>() ?? [];
  } on PlatformException {
    return [];
  }
}
