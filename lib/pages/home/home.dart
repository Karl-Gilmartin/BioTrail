import 'package:bio_trail/pages/explore/explore.dart';

import '../../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> _dropdownItems = [];
  String? _selectedItem;

  @override
  void initState() {
    super.initState();
    _fetchDropdownItems();
  }

  // Fetch dropdown items from Firestore with debugging
  Future<void> _fetchDropdownItems() async {
    try {
      print('Fetching items from Firestore...');
      final QuerySnapshot snapshot =
          await _firestore.collection('Universities').where("name", isNotEqualTo: null).get();

      if (snapshot.docs.isEmpty) {
        print('No documents found in the Universities collection.');
      } else {
        print('Documents found: ${snapshot.docs.length}');
      }

      // Map the Firestore documents to a list of strings
      final List<String> items = snapshot.docs.map((doc) {
        if (doc.data() != null) {
          print('Document data: ${doc.data()}');
        } else {
          print('Document has no data: ${doc.id}');
        }
        return doc['name'] as String;
      }).toList();

      if (items.isEmpty) {
        print('No valid items found in the collection.');
      }

      setState(() {
        _dropdownItems = items;
        _selectedItem = _dropdownItems.isNotEmpty ? _dropdownItems[0] : null;
      });

      print('Dropdown items: $_dropdownItems');
    } catch (e) {
      print('Error fetching dropdown items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(context),
      body: buildBody(context),
    );
  }

  // Separate AppBar method
  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: PopupMenuButton<int>(
        icon: const Icon(Icons.account_circle, color: Colors.black),
        onSelected: (item) => _onSelected(context, item),
        itemBuilder: (context) => [
          const PopupMenuItem<int>(value: 0, child: Text('Sign Out')),
        ],
      ),
    );
  }

  // Separate Body method
  Widget buildBody(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(
            'Hello👋',
            style: GoogleFonts.raleway(
              textStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            FirebaseAuth.instance.currentUser?.email ?? 'No User',
            style: GoogleFonts.raleway(
              textStyle: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          // Instruction text above the dropdown
          Text(
            'Please select your university:',
            style: GoogleFonts.raleway(
              textStyle: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Dropdown Button with fallback
          _dropdownItems.isEmpty
              ? const Text('No items available', style: TextStyle(color: Colors.red))
              : DropdownButton<String>(
                  value: _selectedItem,
                  items: _dropdownItems.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedItem = newValue!;
                    });
                  },
                  style: GoogleFonts.raleway(
                    textStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                  dropdownColor: Colors.white,
                ),
          const Spacer(), // Push the explore button to the bottom

          // Explore Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0D6EFD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                minimumSize: const Size(double.infinity, 60),
                elevation: 0,
              ),
              onPressed: () {
                

                // go to explore page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Explore(),
                  ),
                );
              },
              child: const Text(
                "Explore",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Sign Out logic in the menu
  void _onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        _logout(context);
        break;
    }
  }

  // Logout Function
  Future<void> _logout(BuildContext context) async {
    try {
      print('Signing out...');
      await AuthService().signout(context: context);
    } catch (e) {
      print('Error during sign out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }
}
