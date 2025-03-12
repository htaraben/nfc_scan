import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart';

class CountryComparison {
  final String country1;
  final String country2;

  CountryComparison(this.country1, this.country2);

  Future<String> compare() async {
    String jsonString = await rootBundle.loadString('assets/data.json');
    List<dynamic> nfcDataList = json.decode(jsonString);

    if (country1.isEmpty || country2.isEmpty) {
      return 'Ein oder beide Ländernamen sind nicht in der Datenbank.';
    }

    Map<String, dynamic>? c1 = nfcDataList.firstWhere(
      (item) => item["id"] == country1,
      orElse: () => {"error": "No record found!"},
    );

    Map<String, dynamic>? c2 = nfcDataList.firstWhere(
      (item) => item["id"] == country2,
      orElse: () => {"error": "No record found!"},
    );

    if (c1.containsKey("error") || c2.containsKey("error")) {
      return 'Ein oder beide Länder wurden nicht gefunden.';
    }

    String country1name = c1['title'] ?? 'Unbekannt';
    String country2name = c2['title'] ?? 'Unbekannt';

    double latDiff = ((c1["latitude"] as num).toDouble() - (c2["latitude"] as num).toDouble());
    double longDiff = ((c1["longitude"] as num).toDouble() - (c2["longitude"] as num).toDouble());

    if (latDiff == 0 && longDiff == 0) {
      return '$country1name befindet sich an derselben Position wie $country2name.';
    }

    // Berechne den Winkel (0° = Norden, 90° = Osten usw.)
    double angleRadians = math.atan2(longDiff, latDiff);
    double angleDegrees = angleRadians * 180 / math.pi;
    if (angleDegrees < 0) angleDegrees += 360;

    // 16-Punkte-Kompassrose:
    List<String> directions = [
      "nördlich",          // 0
      "nord-nordöstlich",   // 1
      "nordöstlich",        // 2
      "ost-nordöstlich",    // 3
      "östlich",            // 4
      "ost-südöstlich",     // 5
      "südöstlich",         // 6
      "süd-südöstlich",     // 7
      "südlich",            // 8
      "süd-südwestlich",    // 9
      "südwestlich",        // 10
      "west-südwestlich",   // 11
      "westlich",           // 12
      "west-nordwestlich",  // 13
      "nordwestlich",       // 14
      "nord-nordwestlich"   // 15
    ];

    int index = (((angleDegrees + 11.25) % 360) / 22.5).floor();
    String relativeLocation = directions[index];

    // Berechne die ungefähre Distanz (in Grad, nicht km)
    double approxDistance = math.sqrt(latDiff * latDiff + longDiff * longDiff);

    // Wenn die Länder weit auseinander liegen, ergänze die Beschreibung.
    // Threshold kann angepasst werden, hier als Beispiel > 10 Grad.
    String farText = approxDistance > 10 ? " und weit entfernt" : "";

    return '$country1name befindet sich $relativeLocation$farText von $country2name.';
  }
}