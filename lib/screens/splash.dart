import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ranjy_brayan/screens/home.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    // Add a delay or use any other logic if needed before navigating
    Future.delayed(const Duration(seconds: 6), () {
      _navigateToHomeScreen();
    });
  }

  void _navigateToHomeScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Customize the background color if needed
      body: Center(
        child: LottieBuilder.asset(
          'assets/animation.json', // Replace with the path to your Lottie animation file
          width: double.infinity, // Adjust the width as needed
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
