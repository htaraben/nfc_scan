import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

class RandomIdPicker {
  List<String> _ids = [];
  List<String> _remainingIds = [];
  final Random _random = Random();

  // Load IDs from JSON file
  Future<void> loadIds(String jsonPath) async {
    String jsonString = await rootBundle.loadString(jsonPath);
    List<dynamic> jsonData = jsonDecode(jsonString);
    _ids = jsonData.map((item) => item['id'].toString()).toList();
    _remainingIds = List.from(_ids);
  }

  // Get a random ID without repeating
  String? getRandomId() {
    if (_remainingIds.isEmpty) {
     
      return null;
    }

    int index = _random.nextInt(_remainingIds.length);
    String chosenId = _remainingIds.removeAt(index);
    return chosenId;
  }

  // Reset the list if needed
  void reset() {
    _remainingIds = List.from(_ids);
  }
}
