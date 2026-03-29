
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

class Network{


  static Future<String?> getCheckOut() async {
    final url = Uri.parse('https://eu-test.oppwa.com/v1/checkouts');

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer OGE4Mjk0MTc0ZDA1OTViYjAxNGQwNWQ4MjllNzAxZDF8OVRuSlBjMm45aA==",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "entityId": "8a8294174d0595bb014d05d829cb01cd",
        "amount": "92.00",
        "currency": "SAR",
        "paymentType": "DB",
        "integrity": "true",
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);

      dev.log(data['id'].toString(), name: "checkoutId");

      return data['id'];
    } else {
      dev.log(response.body.toString(), name: "STATUS CODE ERROR");
      return null;
    }
  }
 static Future<String?>  getpaymentstatus(checkoutid) async {

    final myUrl = Uri.parse("https://eu-test.oppwa.com/v1/checkouts/$checkoutid/payment");
    final response = await http.get(
      myUrl,

    );
    dev.log((response.body), name: "checkoutId status");

    var data = json.decode(response.body);


    print("payment_status: ${data["result"].toString()}");

    return  data["result"].toString();



  }


}
