import 'package:flutter/material.dart';
import 'package:nfc_scan/core/presentation/screen/nfc_reader.dart';

import 'core/presentation/screen/country_quiz.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
   @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFC SCANNER',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: NFCReaderScreen(),
      routes: {
        '/country_quiz': (context) => CountryQuizScreen(),
      },
    );
  }

}
