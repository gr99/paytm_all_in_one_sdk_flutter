import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:new_app/edit_text.dart';
import 'package:paytm_allinonesdk/paytm_allinonesdk.dart';

void main() {
  runApp(MyApp());
}

class User {
  String id;
  String first_name;
  String last_name;
  String mobileno;
  String email;

  User(this.id, this.first_name, this.last_name, this.mobileno, this.email);

  factory User.fromJson(dynamic json) {
    return User(
        json['_id'] as String,
        json['first_name'] as String,
        json['last_name'] as String,
        json['mobileno'] as String,
        json['email'] as String);
  }

  @override
  String toString() {
    return '{ ${this.id},${this.first_name}, ${this.last_name},${this.mobileno},${this.email} }';
  }
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
  Future<String> generateToken() async {
    print("Hii");
    await http
        .post(Uri.parse("http://10.0.2.2:3100/generateTxnToken"),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8'
            },
            body: jsonEncode({
              "amount": amount,
              "orderId": orderId,
              "custId": user.id,
              "email": user.email,
              "mobile": user.mobileno,
              "mode": 1,
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

  fetchDate() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    //
    // String token =prefs.getString('token');
    String token =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYwMDliOGRjM2UxNWQ1MzJlY2UzYTU2ZSIsImlhdCI6MTYxODIxOTQxM30.yPh873atIC49ppZllsuG6O09_tPG5cbz07-dr7JoS8M";
    final response =
        await http.post(Uri.parse("http://10.0.2.2:3000/personal_info"),
            headers: {
              'Content-Type': 'application/json;charset=UTF-8',
            },
            body: jsonEncode({"token": token}));
    if (response.statusCode == 200) {
      user = User.fromJson(jsonDecode(response.body)['user']);
      if (user != null) {
        generateToken();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDate();
    print("inint");
  }

  bool isloading = true;
  var response;
  User user;
  String mid = "hhmpXO40944790524496",
      custId = "Cust_12345678",
      amount = "22",
      txnToken,email , mobile ;

  var result;
  bool isStaging = false;
  bool isApiCallInprogress = true;
  String orderId = "Order_" + DateTime.now().millisecondsSinceEpoch.toString();
  String callbackUrl =
      "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=";

  bool restrictAppInvoke = false;
  var res;

  @override
  Widget build(BuildContext context) {
    fetchDate() async {
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // String token =prefs.getString('token');
      final response =
          await http.post(Uri.parse("http://10.0.2.2:3000/personal_info"),
              headers: {
                'Content-Type': 'application/json;charset=UTF-8',
              },
              body: jsonEncode({
                "token":
                    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYwMDliOGRjM2UxNWQ1MzJlY2UzYTU2ZSIsImlhdCI6MTYxODIxOTQxM30.yPh873atIC49ppZllsuG6O09_tPG5cbz07-dr7JoS8M"
              }));
      if (response.statusCode == 200) {
        // setState(() {
        user = User.fromJson(jsonDecode(response.body)['user']);
        // });
      }
    }

    return Card(
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              // EditText('Merchant ID', mid, onChange: (val) => mid = val),
              EditText('Order ID', orderId, onChange: (val) => orderId = val),
              EditText('Amount', amount, onChange: (val) => amount = val),
              EditText('Transaction Token', txnToken),
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
                          // print(user.first_name);
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
