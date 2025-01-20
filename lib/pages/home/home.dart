import 'package:bio_trail/pages/explore/explore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bio_trail/tabs/recent_sightings.dart';

class HomePage extends StatefulWidget {
  final String userName;

  const HomePage({Key? key, required this.userName}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedTabIndex = 0; // Keeps track of the selected tab
  int selectedBottomNavIndex = 0; // Keeps track of the bottom navigation index

  // Define the content for each tab
  final List<Widget> tabs = [
    Center(child: Text('Your Feed')), // Placeholder for Your Feed tab
    RecentSightingsTab(), // The Recent Sightings tab
    Center(child: Text('News')), // Placeholder for News tab
  ];

  // Define the content for the BottomNavigationBar
  final List<Widget> bottomNavScreens = [
    Center(child: Text('Home Screen')), // Placeholder for Home screen
    ExplorePage(),
    Center(child: Text('Profile Screen')), // Placeholder for Profile screen
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark, // Makes status bar icons black
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: selectedBottomNavIndex == 0 // Show tabs only on "Home"
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Message
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: MediaQuery.of(context).size.width *
                            0.8, // 80% width for the green bar
                        padding: const EdgeInsets.all(20.0),
                        color: Color.fromRGBO(10, 86, 86, 1), // Dark green background
                        child: Text(
                          'Welcome back, ${widget.userName} !!',
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
                        _buildTabButton('Your Feed', 0),
                        _buildTabButton('Recent Sightings', 1),
                        _buildTabButton('News', 2),
                      ],
                    ),
                    SizedBox(height: 8),

                    // Dynamic Content for the Selected Tab
                    Expanded(child: tabs[selectedTabIndex]),
                  ],
                )
              : bottomNavScreens[selectedBottomNavIndex], // Other bottom nav screens
        ),
        // Bottom Navigation Bar
        bottomNavigationBar: Container(
  height: 88, // Default height for BottomNavigationBar
  child: BottomNavigationBar(
    backgroundColor: Color.fromRGBO(173, 182, 169, 1), // Light green background
    selectedItemColor: Color.fromRGBO(10, 86, 86, 1), // Dark green for selected
    unselectedItemColor: Colors.black45,
    iconSize: 20, // Reduce the icon size
    selectedIconTheme: IconThemeData(size: 24), // Customize the selected icon size
    unselectedIconTheme: IconThemeData(size: 20), // Customize the unselected icon size
    selectedLabelStyle: TextStyle(fontSize: 12), // Ensure label text fits

    unselectedLabelStyle: TextStyle(fontSize: 12),
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.explore),
        label: 'Explore',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ],
    currentIndex: selectedBottomNavIndex, // Updates the current selected index
    onTap: (index) {
      setState(() {
        selectedBottomNavIndex = index; // Update the bottom nav index
      });
    },
  ),
),
      ),
    );
  }

  // Helper method to build navigation tabs
  Widget _buildTabButton(String title, int index) {
    final bool isSelected = selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTabIndex = index; // Change the selected tab
        });
      },
      child: Container(
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
      ),
    );
  }
}
