import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class CountryQuizScreen extends StatefulWidget {
  const CountryQuizScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CountryQuizScreenState createState() => _CountryQuizScreenState();
}

class _CountryQuizScreenState extends State<CountryQuizScreen> {
  Map<String, dynamic>? countryData;
  bool isInfoVisible = false;
  String? selectedAnswer;
  bool isAnswerCorrect = false;
  int currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    loadCountryData();
  }

  Future<void> loadCountryData() async {
    String jsonString = await rootBundle.loadString('assets/data.json');
    List<dynamic> jsonData = json.decode(jsonString);
    setState(() {
      countryData = jsonData.firstWhere((item) => item["id"] == "RU", orElse: () => null);
      if (countryData != null && countryData!["quiz"] != null && countryData!["quiz"]["questions"] is List) {
        currentQuestionIndex = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: countryData == null
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          
          Expanded(
            flex: 11,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  alignment: Alignment.topCenter,
                  child: Text(
                    countryData!["quiz"]["questions"][currentQuestionIndex]["question"],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: countryData!["quiz"]["questions"][currentQuestionIndex]["options"].length,
                    itemBuilder: (context, index) {
                      String path = countryData!["quiz"]["questions"][currentQuestionIndex]["options"][index];
                      bool isSelected = selectedAnswer == path;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedAnswer = path;
                            isAnswerCorrect = path == countryData!["quiz"]["questions"][currentQuestionIndex]["correctAnswer"];
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? (isAnswerCorrect ? Colors.green : Colors.red)
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
                                  color: Colors.green.withOpacity(0.6), // Semi-transparent green overlay
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Richtig!",
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),

                        ),
                      );
                    },
                  ),
                ),
                if (selectedAnswer != null && isAnswerCorrect)
                  Padding(
                    padding: EdgeInsets.all(16),
                    child:  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (countryData?["quiz"]?["questions"] != null &&
                              currentQuestionIndex < countryData!["quiz"]["questions"].length - 1) {
                            currentQuestionIndex++;
                            selectedAnswer = null;
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text("Quiz beendet!"),
                                content: Text("Du hast alle Fragen beantwortet! 🎉"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
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
                  )],
            ),
          ),
        ],
      ),
    );
  }
}