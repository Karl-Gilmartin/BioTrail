import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatelessWidget {
  final String userName;

  const HomePage({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark, // Makes status bar icons black
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Message
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8, // 80% width for the green bar
                  padding: const EdgeInsets.all(20.0),
                  color: Color.fromRGBO(10, 86, 86, 1), // Dark green background
                  child: Text(
                    'Welcome back, $userName !!',
                    style: TextStyle(
                      fontSize: 32, // Font size for welcome message
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Navigation Tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTabButton('Your Feed', isSelected: true),
                  _buildTabButton('Recent Sightings'),
                  _buildTabButton('News'),
                ],
              ),
              SizedBox(height: 8),

              // Placeholder for content with padding
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0), // Padding for the grey section
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Bottom Navigation Bar
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color.fromRGBO(173, 182, 169, 1), // Light green background
          selectedItemColor: Color.fromRGBO(10, 86, 86, 1), // Dark green for selected
          unselectedItemColor: Colors.black45,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '',
            ),
          ],
          currentIndex: 0, // Set the selected index
          onTap: (index) {
            // Handle navigation tap
          },
        ),
      ),
    );
  }

  // Helper method to build navigation tabs
  Widget _buildTabButton(String title, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: isSelected
            ? Color.fromRGBO(10, 86, 86, 1)
            : Color.fromRGBO(173, 182, 169, 1), // Selected and unselected colors
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
