import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ranjy_brayan/screens/home.dart';
import 'package:ranjy_brayan/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  late SharedPreferences _prefs;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    // Initialize shared preferences
    initSharedPreferences();
    print(isLoggedIn);
    Future.delayed(const Duration(seconds: 6), () {
      _navigateToNextScreen();
    });
  }

  Future<void> initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = _prefs.getBool('isLoggedIn') ?? false;
    });
  }

  void _navigateToNextScreen() {
    if (isLoggedIn) {
      _navigateToHomeScreen();
    } else {
      _navigateToLoginScreen();
    }
  }

  void _navigateToHomeScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ),
    );
  }

  void _navigateToLoginScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: LottieBuilder.asset(
          'assets/animation.json',
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
