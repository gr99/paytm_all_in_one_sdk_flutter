// in sublime
var express = require('express');
var port = 3100;
var app = express();

const https = require('https');

const checksum_lib = require('./checksum');
const PaytmChecksum = require("./paytm_checksum");


app.use(express.json()); // to support JSON-encoded bodies
app.use(express.urlencoded()); //

app.get('/', function (req, res) {
    res.send(JSON.stringify({Hello: 'World'}));
});
app.post('/generateTxnToken', function (request, res) {

    // console.log(request);
    console.log(request.body);


    /* initialize an object */
    var paytmParams = {};
    var MID = "hhmpXO40944790524496";
    var key_secret = "Qg#wY%vd55BW%M9r";

    var orderId = request.body.orderId;
    var amount = parseFloat(String(request.body.amount));

    var custId = request.body.custId;
    var email = request.body.email;
    var mobile = String(request.body.mobile);
    // var callbackUrl = request.body.callbackUrl;
    var callbackUrl = `https://securegw-stage.paytm.in/theia/paytmCallback?mid=hhmpXO40944790524496&ORDER_ID=` + orderId;
    var mode = String(request.body.mode);
    var website = request.body.website;
    var testing = String(request.body.testing);
    // console.log(callbackUrl);
    // console.log(mode);

    /* query parameters */
    paytmParams.body = {

        /* for custom checkout value is 'Payment' and for intelligent router is 'UNI_PAY' */
        "requestType": "Payment",

        /* Find your MID in your Paytm Dashboard at https://dashboard.paytm.com/next/apikeys */
        "mid": MID,

        /* Find your Website Name in your Paytm Dashboard at https://dashboard.paytm.com/next/apikeys */
        "websiteName": website == undefined ? "DEFAULT" : website,

        /* Enter your unique order id */
        "orderId": orderId,

        /* on completion of transaction, we will send you the response on this URL */
        // "callbackUrl": "https://mrdishant.com",
        "callbackUrl": callbackUrl,

        /* Order Transaction Amount here */
        "txnAmount": {

            /* Transaction Amount Value */
            "value": amount,

            /* Transaction Amount Currency */
            "currency": "INR",
        },

        /* Customer Infomation here */
        "userInfo": {

            /* unique id that belongs to your customer */
            "custId": "custId_12300",
            "email": email,
            "mobile": mobile

        },

    };

    // console.log("Mode");
    // console.log(mode);

    if (mode == "1") {
        console.log("Mode 1 So Net Banking");
        paytmParams.body[
            "enablePaymentMode"] = [{
            "mode": "NET_BANKING",
        }]
    } else if (mode == "0") {
        console.log("Mode 0 So BALANCE");
        paytmParams.body[
            "enablePaymentMode"] = [{
            "mode": "BALANCE",
        }]
    } else if (mode == "2") {
        console.log("Mode 2 So UPI");
        paytmParams.body[
            "enablePaymentMode"] = [{
            "mode": "UPI",
        }]
    } else if (mode == "3") {
        console.log("Mode 3 So CC");
        paytmParams.body[
            "enablePaymentMode"] = [{
            "mode": "CREDIT_CARD"
        }]
    }

    // console.log(JSON.stringify(paytmParams));

    /**
     * Generate checksum by parameters we have in body
     * Find your Merchant Key in your Paytm Dashboard at https://dashboard.paytm.com/next/apikeys
     */
    checksum_lib.genchecksumbystring(JSON.stringify(paytmParams.body), key_secret, (err, checksum) => {

        if (err) {
            return;
        }

        /* head parameters */
        paytmParams.head = {

            /* put generated checksum value here */
            "signature": checksum
        };

        /* prepare JSON string for request */
        var post_data = JSON.stringify(paytmParams);

        var options = {


            /* for Staging */


            /* for Production */
            hostname: testing == "0" ? 'securegw-stage.paytm.in' : 'securegw.paytm.in',

            port: 443,
            path: '/theia/api/v1/initiateTransaction?mid=hhmpXO40944790524496&orderId=' + orderId,
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': post_data.length
            }
        };

        // Set up the request
        var response = "";
        var post_req = https.request(options, (post_res) => {
            post_res.on('data', (chunk) => {
                response += chunk;
            });

            post_res.on('end', () => {
                // console.log(orderId);
                console.log('Response: ', response);
                response = JSON.parse(response);
                res.json(response.body.txnToken);
                return 0;
            });
        });

        // post the data
        post_req.write(post_data);
        post_req.end();
    });
});

app.post('/tran_status', function (request, res) {

    // console.log(request);
    console.log(request.body);


    /* initialize an object */
    var paytmParams = {};
    var MID = "hhmpXO40944790524496";
    var key_secret = "Qg#wY%vd55BW%M9r";

    var orderId = request.body.orderId;
    var amount = parseFloat(String(request.body.amount));

    var custId = request.body.custId;
    var email = request.body.email;
    var mobile = String(request.body.mobile);
    // var callbackUrl = request.body.callbackUrl;
    var callbackUrl = `https://securegw-stage.paytm.in/theia/paytmCallback?mid=hhmpXO40944790524496&ORDER_ID=` + orderId;
    var mode = String(request.body.mode);
    var website = request.body.website;
    var testing = String(request.body.testing);
    // console.log(callbackUrl);
    // console.log(mode);

    /* query parameters */
    paytmParams.body = {

        /* for custom checkout value is 'Payment' and for intelligent router is 'UNI_PAY' */
        // "requestType": "Payment",

        /* Find your MID in your Paytm Dashboard at https://dashboard.paytm.com/next/apikeys */
        "mid": MID,

        /* Find your Website Name in your Paytm Dashboard at https://dashboard.paytm.com/next/apikeys */
        // "websiteName": website == undefined ? "DEFAULT" : website,

        /* Enter your unique order id */
        "orderId": orderId,

        /* on completion of transaction, we will send you the response on this URL */
        // "callbackUrl": "https://mrdishant.com",
        // "callbackUrl": callbackUrl,

        /* Order Transaction Amount here */
        // "txnAmount": {

            /* Transaction Amount Value */
            // "value": amount,

            /* Transaction Amount Currency */
            // "currency": "INR",
        // },

        /* Customer Infomation here */
        // "userInfo": {
        //
        //     /* unique id that belongs to your customer */
        //     "custId": "custId_12300",
        //     "email": email,
        //     "mobile": mobile
        //
        // },

    };


    // console.log(JSON.stringify(paytmParams));

    /**
     * Generate checksum by parameters we have in body
     * Find your Merchant Key in your Paytm Dashboard at https://dashboard.paytm.com/next/apikeys
     */
    checksum_lib.genchecksumbystring(JSON.stringify(paytmParams.body), key_secret, (err, checksum) => {

        if (err) {
            return;
        }

        /* head parameters */
        paytmParams.head = {

            /* put generated checksum value here */
            "signature": checksum
        };

        /* prepare JSON string for request */
        var post_data = JSON.stringify(paytmParams);

        var options = {


            /* for Staging */


            /* for Production */
            hostname: testing == "0" ? 'securegw-stage.paytm.in' : 'securegw.paytm.in',

            port: 443,
            path: '/v3/order/status',
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Content-Length': post_data.length
            }
        };

        // Set up the request
        var response = "";
        var post_req = https.request(options, (post_res) => {
            post_res.on('data', (chunk) => {
                response += chunk;
            });

            post_res.on('end', () => {
                // console.log(orderId);
                console.log('Response: ', response);
                response = JSON.parse(response);
                res.json(post_data);
                return 0;
            });
        });

        // post the data
        post_req.write(post_data);
        post_req.end();
    });
});


app.listen(port, function () {
    console.log(`Example app listening on port !`);
});



