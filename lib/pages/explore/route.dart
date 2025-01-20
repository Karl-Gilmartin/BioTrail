import 'package:flutter/material.dart';

class RoutePage extends StatelessWidget {
  final String universityId;
  final String universityName;

  const RoutePage({Key? key, required this.universityId, required this.universityName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(universityName),
        backgroundColor: Color.fromRGBO(10, 86, 86, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Explore $universityName",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to NFC scan
              },
              child: Text("Scan NFC"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navigate to Record Sighting
              },
              child: Text("Record Sighting"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navigate to Report Issue
              },
              child: Text("Report Issue"),
            ),
          ],
        ),
      ),
    );
  }
}
