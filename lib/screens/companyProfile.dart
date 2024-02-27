import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:ranjy_brayan/screens/companies.dart';
import 'package:ranjy_brayan/screens/home.dart';
import 'package:ranjy_brayan/screens/profile.dart';

class CompanyProfile extends StatefulWidget {
  @override
  State<CompanyProfile> createState() => _CompanyProfileState();
}

class _CompanyProfileState extends State<CompanyProfile> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    int _bottomNavIndex = 3;

    List<IconData> iconList = [
      Icons.home,
      Icons.person,
      Icons.place_rounded,
      Icons.settings
    ];

    void navigateToHomeScreen() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    }

    void navigateToProfileScreen() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ),
      );
    }

    void navigateToCompaniesScreen() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const CompaniesScreen(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF252526),
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex: _bottomNavIndex,
        activeColor: Colors.white,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.verySmoothEdge,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        backgroundColor: Color(0xFFFFD700),
        onTap: (index) {
          setState(() => _bottomNavIndex = index);
          switch (index) {
            case 0:
              // Home
              navigateToHomeScreen();
              break;
            case 1:
              // Profile
              navigateToProfileScreen();
              break;
            case 2:
              // Companies
              navigateToCompaniesScreen();
              break;
            case 3:
              // Settings or other page

              break;
          }
        },
      ),
      appBar: AppBar(
        title: const Text('پرۆفایلی کۆمپانیا'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              height: screenHeight / 2,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('assets/tt.jpg'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'برایان',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              'About the Company: Lorem ipsum dolor sit amet, consectetur adipiscing elit....', // Replace with your company description
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
