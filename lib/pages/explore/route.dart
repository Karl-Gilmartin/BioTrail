import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:nfc_manager/nfc_manager.dart';

class RoutePage extends StatelessWidget {
  final String universityId;
  final String universityName;

  const RoutePage({Key? key, required this.universityId, required this.universityName})
      : super(key: key);

  // Function to scan NFC
  void _scanNFC() async {
    print("Scanning started");

    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          print("Tag discovered: ${tag.data}");
          _stopNFCScanSession();
        },
      );
    } catch (e) {
      print("NFC scan failed: $e");
    }
  }

  void _stopNFCScanSession() async{
    await NfcManager.instance.stopSession();
  }

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
              onPressed: () => _scanNFC(),
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
