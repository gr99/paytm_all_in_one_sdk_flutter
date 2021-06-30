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

  generateToken(String amount) async {
    await http
        .post(Uri.parse("http://10.0.2.2:3100/generateTxnToken"),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8'
            },
            body: jsonEncode({
              "amount": amount,
              "orderId": orderId,
              //orderId must Be unique
              "custId": "User_12334343453",
              "email": "Gaurav.bidwai99@gmail.com",
              "mobile": "7219240747",
              "mode": 1,
              //For "0":Balance,"1":Net Banking,,"2":UPI,"3":Credit Card or Dabit Card
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
      amount = "22",
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
                  onPressed: () {
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
          Navigator.push(context, MaterialPageRoute (
            builder: (BuildContext context) => ConvertString(result: result,),
          ),);
        });
      }).catchError((onError) {
        if (onError is PlatformException) {
          setState(() {
            result = onError.message + " \n  " + onError.details.toString();
            Navigator.push(context, MaterialPageRoute (
              builder: (BuildContext context) => ConvertString(result: onError.details,),
            ),);
          });
        } else {
          setState(() {
            result = onError.toString();
            Navigator.push(context, MaterialPageRoute (
              builder: (BuildContext context) => ConvertString(result: onError,),
            ),);
          });
        }
      });
    } catch (err) {
      result = err.message;
    }
  }
}


class Result {
  String status;
  String bankName;
  String payMode;
  String txnId;
  String bankTxnId;
  String rspMsg;
  String txnDate;

  Result(this.status,this.bankName, this.payMode, this.txnId, this.bankTxnId, this.rspMsg,this.txnDate);

  factory Result.fromJson(dynamic json) {
    return Result(
        json['STATUS'] as String,
        json['GATEWAYNAME'] as String,
        json['PAYMENTMODE'] as String,
        json['TXNID'] as String,
        json['BANKTXNID'] as String,
        json['RESPMSG'] as String,
        json['TXNDATE'] as String);

  }

  @override
  String toString() {
    return '{ ${this.status},${this.bankName}, ${this.payMode},${this.txnId},${this.bankTxnId},${this.rspMsg},${this.txnDate} }';
  }
}

class ConvertString extends StatefulWidget {
  final result;
  const ConvertString({this.result});

  @override
  _ConvertStringState createState() => _ConvertStringState();
}

class _ConvertStringState extends State<ConvertString> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child:
    Center(
      child: ElevatedButton(
        child: Text("Convert"),
        onPressed: (){
          Result user = Result.fromJson(widget.result);
          print(user);
        }
      ),
    )
    );
  }
}
