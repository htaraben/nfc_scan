import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    loadLocalData();
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

    setState(() {
      _nfcData = "Scan an NFC tag to see the data.";
      isLoading = true;
      scannedData = null;
    });
    
    
    bool isAvailable = await NfcManager.instance.isAvailable();
    
                  
    if (!isAvailable) {
      setState(() {
        _nfcData = "NFC is not available on this device.";
      });
      return;
    }

    try {
      await NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        // Extract NDEF records from the tag
        var ndef = Ndef.from(tag);
        if (ndef == null) {
          setState(() {
            _nfcData = "NDEF format not supported on this tag.";
          });
          return;
        }

        // Read NDEF message
        NdefMessage message = await ndef.read();
        for (NdefRecord record in message.records) {
          if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown &&
              record.payload.isNotEmpty &&
              record.payload[0] == 0x02) {
            // Decode text (skip language code bytes)
            String decodedText = utf8.decode(record.payload.sublist(3));

            Map<String, dynamic>? result = nfcDataList.firstWhere(
                            (item) => item["id"] == decodedText.toString(),
                            orElse: () => {"error": "No record found!"},
                          );
                          
                setState(() {
                    isLoading = false;
                    _nfcData = "NFC Chip successful scanned";
                    scannedData = result;
                  });
            
            setState(() {
              _nfcData = "NFC Text is: $decodedText";
              
            });
          } else {
            setState(() {
              _nfcData = "No text found on this tag.";
            });
          }
        }

        // Stop NFC session
        NfcManager.instance.stopSession();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('NFC Reader')),
      body: Center(
        
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_nfcData, textAlign: TextAlign.center),
            SizedBox(height: 20),
            ElevatedButton(
              
              onPressed: _readNfcTag,
              child: Text('Scan NFC'),

            ),

            isLoading
                  ? CircularProgressIndicator()
                  : scannedData != null
                      ? InfoCard(data: scannedData!)
                      : Text('No data scanned'),
           
          ],

          
        ),
        
      ),
    );
  }
}
