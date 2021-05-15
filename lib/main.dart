import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:new_app/edit_text.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';

void main() {
  runApp(MyApp()
      // MyApp()
      );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter App'),
        ),
        body: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  String orderId = "Order_" + DateTime.now().millisecondsSinceEpoch.toString();

  Future<String> generateToken(String amount) async {
    print("Hii");
    await http
        .post(Uri.parse("http://10.0.2.2:3100/generateTxnToken"),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8'
            },
            body: jsonEncode({
              "amount": amount,
              "orderId": orderId, //orderId must Be unique
              "custId": "User_12334343453",
              "email": "Gaurav.bidwai99@gmail.com",
              "mobile": "7219240747",
              "mode": 3,//For "0":Balance,"1":Net Banking,,"2":UPI,"3":Credit Card or Dabit Card
              "website": "WEBSTAGING",
              "testing": 0
            }))
        .then((value) => txnToken = json.decode(value.body));
    if (txnToken != null) {
      setState(() {
        isApiCallInprogress = false;
      });
    }
  }
  bool isloading = true;
  var response;
  String mid = "hhmpXO40944790524496",
      custId = "Cust_12345678",
      amount="22",
      txnToken,
      email,
      mobile;

  var result;
  bool isStaging = false;
  bool isApiCallInprogress = true;
  String callbackUrl =
      "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=";

  bool restrictAppInvoke = false;
  var res;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              // EditText('Merchant ID', mid, onChange: (val) => mid = val),
              EditText(
                'Order ID',
                orderId,
                onChange: (val) => orderId = val,
                isEnabled: false,
              ),
              EditText(
                'Amount',
                amount,
                onChange: (val) => amount = val,
                isEnabled: true,
              ),
              Container(
                margin: EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed:() {
                    generateToken(amount);
                  },
                  child: Text('Fetch Token'),
                ),
              ),
              EditText(
                'Transaction Token',
                txnToken,
                isEnabled: false,
              ),
              Row(
                children: <Widget>[
                  Checkbox(
                      activeColor: Theme.of(context).buttonColor,
                      value: isStaging,
                      onChanged: (bool val) {
                        setState(() {
                          isStaging = val;
                        });
                      }),
                  Text("Staging")
                ],
              ),
              Row(
                children: <Widget>[
                  Checkbox(
                      activeColor: Theme.of(context).buttonColor,
                      value: restrictAppInvoke,
                      onChanged: (bool val) {
                        setState(() {
                          restrictAppInvoke = val;
                        });
                      }),
                  Text("Restrict AppInvoke")
                ],
              ),
              Container(
                margin: EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: isApiCallInprogress
                      ? null
                      : () {
                          _startTransaction();
                        },
                  child: Text('Start Transcation'),
                ),
              ),
              Container(
                alignment: Alignment.bottomLeft,
                child: Text("Message : "),
              ),
              Container(
                child: Text(result.toString()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startTransaction() async {
    if (txnToken.isEmpty) {
      return;
    }
    try {
      var response = AllInOneSdk.startTransaction(
          mid, orderId, amount, txnToken, null, isStaging, restrictAppInvoke);
      response.then((value) {
        setState(() {
          result = value;
        });
      }).catchError((onError) {
        if (onError is PlatformException) {
          setState(() {
            result = onError.message + " \n  " + onError.details.toString();
          });
        } else {
          setState(() {
            result = onError.toString();
          });
        }
      });
    } catch (err) {
      result = err.message;
    }
  }
}
