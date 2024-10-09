
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

class Network{


 static Future<String?> getCheckOut() async {
    final url = Uri.parse('https://dev.hyperpay.com/hyperpay-demo/getcheckoutid.php');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      dev.log(json.decode(response.body)['id'].toString(), name: "checkoutId");

      return json.decode(response.body)['id'];
    }else{
      dev.log(response.body.toString(), name: "STATUS CODE ERROR");
      return null;
    }
  }
 static Future<String?>  getpaymentstatus(checkoutid) async {

    final myUrl = Uri.parse("http://dev.hyperpay.com/hyperpay-demo/getpaymentstatus.php?id=$checkoutid");
    final response = await http.get(
      myUrl,

    );
    dev.log((response.body), name: "checkoutId status");

    var data = json.decode(response.body);


    print("payment_status: ${data["result"].toString()}");

    return  data["result"].toString();



  }


}