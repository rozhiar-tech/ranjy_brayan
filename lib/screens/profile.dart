import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ranjy_brayan/screens/companies.dart';
import 'package:ranjy_brayan/screens/home.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User? _user;
  UserDetails? _userDetails;
  int _bottomNavIndex = 1;

  List<IconData> iconList = [
    Icons.home,
    Icons.person,
    Icons.house,
    Icons.settings
  ];

  void navigateToHomeScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ),
    );
  }

  void navigateToProfileScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(),
      ),
    );
  }

  void navigateToCompaniesScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CompaniesScreen(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      _getUserDetails();
    }
  }

  Future<void> _getUserDetails() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();

      setState(() {
        _userDetails = UserDetails(
          displayName: userSnapshot['firstName'] ?? '',
          email: userSnapshot['email'] ?? '',
          // Add other user details as needed
        );
      });
    } catch (e) {
      print('Error fetching user details: $e');
      // Handle error appropriately
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex: _bottomNavIndex,
        activeColor: Colors.yellow,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.verySmoothEdge,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: (index) {
          setState(() => _bottomNavIndex = index);
          switch (index) {
            case 0:
              // Home
              navigateToHomeScreen();

              break;
            case 1:
              navigateToProfileScreen();
              // Profile
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
        title: const Text('پەڕەی تایبەت'),
      ),
      body: _user != null
          ? (_userDetails != null
              ? _buildUserProfile()
              : const CircularProgressIndicator())
          : const Center(child: Text('هیچ کەسێ داخڵ نەبووە')),
    );
  }

  Widget _buildUserProfile() {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ناو: ${_userDetails!.displayName}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('ئیمەیڵ: ${_userDetails!.email}'),
                // Add other user details as needed
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UserDetails {
  final String displayName;
  final String email;

  UserDetails({
    required this.displayName,
    required this.email,
  });
}
