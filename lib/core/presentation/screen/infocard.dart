import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const InfoCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 1, // Set custom width
       // Set custom height
      child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // **Title of the Info Section**
                
                Center(
                    child: Text(
                      data['title'] ?? 'Title Not Available',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 32, 31, 31),
                      ),
                    ),
                  ),
                SizedBox(height: 10), // Spacing between title and description
      
                // **Description or Info Content**
                Text(
                  data['description1'] ?? 'No description available.',
                  style: TextStyle(fontSize: 16, color: Colors.black87) ,
                ), // Spacing between title and description
      
                // **Description or Info Content**
                Text(
                  data['description2'] ?? 'No description available.',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ), // Spacing between title and description
      
                // **Description or Info Content**
                Text(
                  data['description3'] ?? 'No description available.',
                  style: TextStyle(fontSize: 16, color: Colors.black87), 
                ),  // Spacing between title and description
      
                // **Description or Info Content**
                Text(
                  data['description4'] ?? 'No description available.',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ),
      
    );
  }
}