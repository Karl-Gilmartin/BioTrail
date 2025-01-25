import 'package:bio_trail/pages/landing/landing.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLanding();
  }

  // Function to navigate to the login page after a delay
  _navigateToLanding() async {
    await Future.delayed(Duration(seconds: 3), () {}); // Delay for 1 second
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LandingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(122, 152, 137, 1), // Match your splash screen background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your logo here
            Image.asset(
              'assets/bio_trail.png', // Replace with your logo's asset path
              height: 300, // Adjust the size
            ),
          ],
        ),
      ),
    );
  }
}
