import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'dart:convert';
import 'package:confetti/confetti.dart'; // Import confetti package

import 'package:nfc_scan/core/presentation/screen/infocard.dart';

class NFCReaderScreen extends StatefulWidget {
  const NFCReaderScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NFCReaderScreenState createState() => _NFCReaderScreenState();
}

class _NFCReaderScreenState extends State<NFCReaderScreen> {
  String _nfcData = "Scan an NFC tag to see the data.";
  List<dynamic> nfcDataList = [];
  Map<String, dynamic>? scannedData;
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
    loadLocalData();
    _readNfcTag();
  }

  // Load JSON data
  Future<void> loadLocalData() async {
    String jsonString = await rootBundle.loadString('assets/data.json');
    setState(() {
      nfcDataList = json.decode(jsonString);
    });
  }

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

            setState(() {
              if (scannedData != null &&
                  scannedData!["quiz"] != null &&
                  scannedData!["quiz"]["questions"] is List) {
                currentQuestionIndex = 0;
              }
            });

            setState(() {
              isLoading = false;

              scannedData = result;
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
      body: Stack(
        children: [
          // **SingleChildScrollView with content**
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // **Loading Indicator**
                if (isLoading)
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height *
                        0.6, // Adjust height as needed
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade200, Colors.blue.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // **Lottie Animation for guiding the kid**
                        Lottie.asset(
                          'assets/animations/place_phone.json', // Ensure you have this file
                          width: 200,
                          height: 200,
                          repeat: true,
                        ),
                        SizedBox(height: 20),

                        // **Instructional Text**
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            _nfcData,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  // **Image Display (if data is scanned)**
                  scannedData != null
                      ? SizedBox(
                          width: double.infinity,
                          height: 300,
                          child: Image.asset(
                            scannedData?['imagePath'] ?? '',
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height *
                              0.6, // Adjust height as needed
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade200,
                                Colors.blue.shade400
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // **Lottie Animation for guiding the kid**
                              Lottie.asset(
                                'assets/animations/place_phone.json', // Ensure you have this file
                                width: 200,
                                height: 200,
                                repeat: true,
                              ),
                              SizedBox(height: 20),

                              // **Instructional Text**
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  _nfcData,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                SizedBox(height: 20), // Spacing between image and info section

                // **Information Section Below the Photo**
                if (scannedData != null) ...[
                  InfoCard(data: scannedData!),
                  SizedBox(height: 20), // Add spacing below the info section

                  // **Quiz Section**
                  if (scannedData != null &&
                      scannedData!["quiz"]?["questions"] != null &&
                      scannedData!["quiz"]["questions"].isNotEmpty) ...[
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        scannedData!["quiz"]["questions"][currentQuestionIndex]
                            ["question"],
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap:
                          true, // Important to prevent unbounded height issues
                      physics:
                          NeverScrollableScrollPhysics(), // Prevents scrolling conflicts
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: scannedData!["quiz"]["questions"]
                              [currentQuestionIndex]["options"]
                          .length,
                      itemBuilder: (context, index) {
                        String path = scannedData!["quiz"]["questions"]
                            [currentQuestionIndex]["options"][index];
                        bool isSelected = selectedAnswer == path;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedAnswer = path;
                              isAnswerCorrect = path ==
                                  scannedData!["quiz"]["questions"]
                                      [currentQuestionIndex]["correctAnswer"];
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? (isAnswerCorrect
                                        ? Colors.green
                                        : Colors.red)
                                    : Colors.transparent,
                                width: 4,
                              ),
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    path,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                if (isSelected && isAnswerCorrect)
                                  Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: Colors.green.withOpacity(0.6),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Richtig!",
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // **Next Question Button**
                    if (selectedAnswer != null)
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (currentQuestionIndex <
                                  scannedData!["quiz"]["questions"].length -
                                      1) {
                                currentQuestionIndex++;
                                selectedAnswer = null;
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("Quiz beendet!"),
                                    content: Text(
                                        "Du hast alle Fragen beantwortet! 🎉"),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Text("OK"),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            });
                          },
                          child: Text("Zur nächsten Frage"),
                        ),
                      ),
                  ],
                ],
              ],
            ),
          ),

          // **Confetti Fireworks Animation**
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: -pi / 2,
              emissionFrequency: 0.1,
              numberOfParticles: 50,
              gravity: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
