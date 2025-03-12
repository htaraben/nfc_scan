import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:nfc_scan/core/presentation/screen/erkunde_die_welt.dart';
import 'package:nfc_scan/core/presentation/screen/suche_ein_land.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌍 Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/world_map.jpeg', // Replace with actual image path
              fit: BoxFit.cover, // Covers the entire screen
            ),
          ),

          // 🎨 Overlay to Improve Text Visibility (Optional)
          Positioned.fill(
            child: Container(
              color:
                  Colors.black.withOpacity(0.3), // Dark overlay for readability
            ),
          ),

          // 🌟 Centered Content (Magnifier + Text)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // **Stack to Place Magnifier Above Text**
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // 🔍 **Magnifier Animation**
                    Padding(
                      padding:
                          EdgeInsets.only(bottom: 220), // Moves magnifier up
                      child: Pulse(
                        infinite: true, // Continuous animation
                        duration: Duration(seconds: 3),
                        child: Icon(
                          Icons.search, // Magnifier icon
                          size: 120,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // **Welcome Text**
                    BounceInDown(
                      duration: Duration(seconds: 1),
                      child: Padding(
                        padding: EdgeInsets.only(top: 20), // Moves text down
                        child: Text(
                          "Willkommen bei Weltentdecker!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Comic Sans MS', // Fun font for kids
                            shadows: [
                              Shadow(
                                blurRadius: 5,
                                color: Colors.black26,
                                offset: Offset(3, 3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20), // Space between text and button
              ],
            ),
          ),

          // ✨ **"Erkunde die Welt" Button at Bottom**
          Align(
  alignment: Alignment.center,
  child: Padding(
    padding: const EdgeInsets.only(top: 350),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 🌍 "Erkunde die Welt" Button
        BounceInUp(
          duration: const Duration(seconds: 1),
          child: ElevatedButton(
            onPressed: () {
              // Navigate to NFC Reader Screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NFCReaderScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 5,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.explore, size: 28, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  "Erkunde die Welt",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20), // Spacing between buttons

        // 📜 New Button: "Suche ein Land"
        BounceInUp(
          duration: const Duration(seconds: 1),
          child: ElevatedButton(
            onPressed: () {
              // Navigate to another page (e.g., Country Facts)
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WhereiscountryPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 5,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.public, size: 28, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  "Suche ein Land",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
),

        ],
      ),
    );
  }
}
