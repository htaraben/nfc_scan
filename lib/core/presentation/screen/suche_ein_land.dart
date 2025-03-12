import 'dart:convert';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_scan/core/presentation/models/random_id_picker.dart';
import 'package:nfc_scan/core/presentation/models/comparecountries.dart';
import 'package:nfc_scan/core/presentation/screen/infocard.dart';

class WhereiscountryPage extends StatefulWidget {
  const WhereiscountryPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WhereiscountryPage createState() => _WhereiscountryPage();
}

class _WhereiscountryPage extends State<WhereiscountryPage> {
  final RandomIdPicker _picker = RandomIdPicker();

  String? _currentId;
  String _status = "";
  String _nfcData = ""; // Store the NFC ID here
  String _compareresult = "";
  List<dynamic> nfcDataList = [];
  Map<String, dynamic>? scannedData;
  Map<String, dynamic>? guesscountryData;
  bool isLoading = false;
  late ConfettiController _confettiController; // Fireworks effect controller

  bool isInfoVisible = false;
  String? selectedAnswer;
  bool isAnswerCorrect = false;
  int currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
        duration: Duration(seconds: 2)); // Fireworks duration
    _loadData();
    _pickCountry();
    _readNfcTag();
  }

  Future<void> _loadData() async {
    setState(() async {
      String jsonString = await rootBundle.loadString('assets/data.json');

      setState(() async {
        nfcDataList = json.decode(jsonString);
      });
    });
  }

  Future<void> _pickCountry() async {
    await _picker.loadIds('assets/data.json');
    String? id = _picker.getRandomId();
    Map<String, dynamic>? result = nfcDataList.firstWhere(
      (item) => item["id"] == id.toString(),
      orElse: () => {"error": "No record found!"},
    );
    setState(() {
      guesscountryData = result;
      _currentId = id;
      _status = id != null ? "Selected ID: $id" : "No more IDs!";
      isLoading = true;
      _status= guesscountryData?["title"];
      // scannedData= result;
    });
  }

// ignore: unused_element
  void _reset() {
    _picker.reset();
    setState(() {
      _status = "List reset! You can pick again.";
      _currentId = null;
    });
  }

  // Function that will handle the ID returned by the NFCReaderScreen
  //void handleScannedId(String id) {
  //  setState(() {
  //  _scannedId = id; // Update the state with the new ID

  // });
  // Now you can use the scanned ID in other functions or UI
  //  print("Scanned ID: $_scannedId");
  // }

  // Function to start NFC scanning session
  Future<void> _readNfcTag() async {
    bool isAvailable = await NfcManager.instance.isAvailable();

    if (!isAvailable) {
      setState(() {
        _nfcData = "NFC is not available on this device.";
      });
      return;
    } else {
      setState(() {
        _nfcData =
            "Platziere dein Telefon auf ein Land der Weltkarte, um mehr darüber zu erfahren!";
        isLoading = true;
        scannedData = null;
      });
    }

    try {
      await NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        var ndef = Ndef.from(tag);
        if (ndef == null) {
          setState(() {
            _nfcData = "NDEF format not supported on this tag.";
          });
          return;
        }

        NdefMessage message = await ndef.read();
        for (NdefRecord record in message.records) {
          if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown &&
              record.payload.isNotEmpty &&
              record.payload[0] == 0x02) {
            String decodedText = utf8.decode(record.payload.sublist(3));

            Map<String, dynamic>? result = nfcDataList.firstWhere(
              (item) => item["id"] == decodedText.toString(),
              orElse: () => {"error": "No record found!"},
            );

            _nfcData = decodedText.toString();
            CountryComparison comparison =
                CountryComparison(_currentId!, _nfcData);

            // Get the comparison result
            String compareresult = await comparison.compare();

            setState(() {
              if (scannedData != null &&
                  scannedData!["quiz"] != null &&
                  scannedData!["quiz"]["questions"] is List) {
                currentQuestionIndex = 0;
              }
            });

            setState(() {
              isLoading = false;
              _nfcData = decodedText.toString();
              scannedData = result;
              _compareresult = compareresult;
            });

            // 🎆 Start fireworks effect when scanned data is found
            _confettiController.play();
          } else {
            setState(() {
              _nfcData = "No text found on this tag.";
            });
          }
        }
      });
    } catch (e) {
      setState(() {
        _nfcData = "Error reading NFC: $e";
        scannedData = {"error": "Error scanning NFC: $e"};
      });
    }
  }

  @override
  void dispose() {
    NfcManager.instance.stopSession();
    _confettiController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Red/Green Box (Title)
          if (scannedData != null && _nfcData != _currentId && !isLoading)
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.red,
                //borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              padding: const EdgeInsets.all(16), // Add padding here
              child: Center(
                child: Text(
                  _compareresult.isNotEmpty ? _compareresult : 'Keine Daten verfügbar',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else if (scannedData != null && _nfcData == _currentId && !isLoading)
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 3, 54, 30),
                //borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ✅ Text: "Richtig!"
                  const Padding(
                    padding: EdgeInsets.only(left: 16),
                    
                    child: Text(
                      'Richtig!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // ✅ Button on the right
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        // Add your function here
                        _pickCountry();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Nächstes Land suchen',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Main Content (Image and InfoCard)
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (scannedData != null) ...[
            // Stack for image and confetti animation
            Stack(
              alignment: Alignment.center,
              children: [
                // Full-width Image (No margin)
                SizedBox(
                  width: double.infinity,
                  height: 250,
                  child: Image.asset(
                    scannedData?['imagePath'] ?? '',
                    fit: BoxFit.cover,
                  ),
                ),
                // Confetti Animation when correct
                if (scannedData != null && _nfcData == _currentId && !isLoading)
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConfettiWidget(
                        confettiController: _confettiController,
                        blastDirection: -pi / 2,
                        emissionFrequency: 0.1,
                        numberOfParticles: 50,
                        gravity: 0.3,
                      ),
                    ),
                  ),
              ],
            ),
            // InfoCard Section after image
            InfoCard(data: scannedData!),
          ],
            
          Center(
            child: Text(
              "Suche das Land :\n\n $_status",
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center, // Center the text inside
            ),
          
          
          ),
          Center(
                 child: Lottie.asset(
                                'assets/animations/place_phone.json', // Ensure you have this file
                                width: 300,
                                height: 300,
                                repeat: true,
                              ),
                             
          )
          // Scanned ID Display
         // Text(
           // "Scanned ID: $_nfcData",
           // style: const TextStyle(fontSize: 18),
         // ),
         // const SizedBox(height: 20),
        ],
      ),
    ),
  );
}




}
