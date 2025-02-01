import 'package:flutter/material.dart';
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
  
  // Function to start NFC scanning session
  Future<void> _readNfcTag() async {
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
            setState(() {
              _nfcData = "NFC Text: $decodedText";
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
              child: Text('Scan NFC Tag'),

            ),
            InfoCard(
            data: {
              'title': 'FRANCE',
              'description1': 'This is an description1 example.',
              'description2': 'This is an description2 example.',
              'description3': 'This is an description3 example.',
              'imageUrl': 'https://ichef.bbci.co.uk/ace/standard/976/cpsprodpb/478C/production/_121561381_gettyimages-976199210.jpg.webp' // Replace with an actual image URL
            },
          ),
          ],

          
        ),
        
      ),
    );
  }
}
