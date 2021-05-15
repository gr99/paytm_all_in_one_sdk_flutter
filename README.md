# PayTM All-in-One SDK Integration In Flutter App.

Flutter project.

## Getting Started

PayTM All-in-One SDK Integration in Flutter App

We will be making an app in flutter which accepts payment using PayTM All-in-One SDK and NodeJS as backend.

# Step 1 :- Create an account on Paytm  as a merchant.
Login to ➡ https://dashboard.paytm.com/login/ with your Paytm account details.Click on API keys under the Developer settings in the left menu.Click the Generate now button under the Test API Details ( Note Down the MID and merchant key).
   

# Step 2 - Download GitHub Repo & Install Dependencies.

  Now, clone the repository from:GitHub - gr99/paytm_all_in_one_sdk_flutter at paytm_all_in_one_sdk_flutter_v1
  
  Install Node Dependencies:
  >cd lib/backend/
  
  >npm install

  Install Flutter Dependencies:
  >cd root-dir
  
  >flutter pub get

# Step 3-.Make Changes in NodeJS API & Flutter APP

  1)In Node API Make change in Server.js Use your MID and Merchant Kay.
  
  2)In Flutter App in Main.dart in Token Request fill Details.


  Note:-For Every Successful and Failed Payment you have Hot Reload the App  because we need Unique Order_Id which will generated only after reload.
  
  
  # To conclude
  
## These repositories have enough code to handle vanilla flow and to test if everything is configured properly. 
## You can add more features in API or even integrate same in another API as well.
