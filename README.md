# nfc_scan
NFC chip scanning and use the id

lib\core\presentation\screen\erkunde_die_welt.dart    //hier is  the nfc reader class//,//it contains the creation of nfc chip reader button and infocard wedgets//
lib\core\presentation\screen\infocard.dart      //hier is  the infocard class//
lib\main.dart                                   //hier is  the main class// 

after clone the project run this comands "flutter clean" and " flutter pub get " To initialize the dependencies
run the command "flutter build apk --release" to build the apk

assets\data.json  //this file contains the data of all contires or NFC-Chips used. This should be modified if you change the map//

assets\photos     //photos that are referenced in the data.json and displayed in the app like DE.jpg//