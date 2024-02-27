import 'dart:io';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ranjy_brayan/screens/admin.dart';
import 'package:ranjy_brayan/screens/companies.dart';
import 'package:ranjy_brayan/screens/companyProfile.dart';
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
  String? userRole;
  String? userName;
  List<IconData> iconList = [
    Icons.home,
    Icons.person,
    Icons.house,
    Icons.settings
  ];

  Future<void> checkSignedInUser() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        setState(() {
          userName = userSnapshot['firstName'];
          userRole = userSnapshot['userRole'];
        });
      } catch (e) {
        print('Error retrieving user data: $e');
      }
    }
  }

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

  String imagUrl = '';

  Future<String?> _getUsername() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();

      imagUrl = userSnapshot['imageUrl'];
      return userSnapshot['firstName'];
    } catch (e) {
      print('Error fetching username: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      _getUserDetails();
      checkSignedInUser();
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
            credit: userSnapshot['credit'] ?? '',
            about: userSnapshot['about'] ?? '');
      });
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: userRole == 'admin'
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                // Show form to add a new company for admin
                // You can navigate to a new page or display a dialog to add a company
                // For example:
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    TextEditingController nameController =
                        TextEditingController();
                    TextEditingController offersController =
                        TextEditingController();
                    File? image;

                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return AlertDialog(
                          title: const Text('زیادکردنی کۆمپانیا'),
                          content: Column(
                            children: [
                              // Image Picker
                              ElevatedButton(
                                onPressed: () async {
                                  final ImagePicker _picker = ImagePicker();
                                  XFile? pickedFile = await _picker.pickImage(
                                      source: ImageSource.gallery);

                                  if (pickedFile != null) {
                                    setState(
                                      () {
                                        image = File(pickedFile.path);
                                      },
                                    );
                                  }
                                },
                                child: const Text('وێنەیەک دیاری بکە'),
                              ),
                              // Display selected image
                              image != null
                                  ? Image.file(
                                      image!,
                                      scale: 1,
                                      height: 50,
                                    )
                                  : const SizedBox.shrink(),
                              // Name TextField
                              TextField(
                                controller: nameController,
                                decoration:
                                    const InputDecoration(labelText: 'ناو'),
                              ),
                              // Offers TextField
                              TextField(
                                controller: offersController,
                                decoration: const InputDecoration(
                                  labelText: 'ئۆفەرەکان (comma-separated)',
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('پاشگەز بونەوە'),
                            ),
                            TextButton(
                              onPressed: () async {
                                if (nameController.text.isNotEmpty &&
                                    offersController.text.isNotEmpty &&
                                    image != null) {
                                  Reference storageReference =
                                      FirebaseStorage.instance.ref().child(
                                          'companies/${DateTime.now().toString()}');
                                  UploadTask uploadTask =
                                      storageReference.putFile(image!);

                                  await uploadTask.whenComplete(() async {
                                    String imageUrl =
                                        await storageReference.getDownloadURL();

                                    // Add the new company to Firestore
                                    await FirebaseFirestore.instance
                                        .collection('companies')
                                        .add({
                                      'imageUrl': imageUrl,
                                      'name': nameController.text,
                                      'offers': offersController.text
                                          .split(',')
                                          .map((e) => e.trim())
                                          .toList(),
                                    });

                                    // Close the dialog
                                    Navigator.pop(context);
                                  });
                                } else {
                                  // Show an error message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'تکایە هەموو ڕوکارەکان پڕ بکەرەوە')),
                                  );
                                }
                              },
                              child: const Text('زیادکردن'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            )
          : FloatingActionButton(
              backgroundColor: const Color(0xFFFFD700),
              child: const Icon(
                Icons.message,
                color: Colors.white,
              ),
              onPressed: () {
                // Show a message for non-admin users
                // For example:
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('لەگەڵ ئادمین گفتوگۆبکە'),
                      content: const Text(
                        'تکایە پەیوەندی بەم ژمارە تەلەفونە بکە بۆ زیاد کردنی کۆمپانیا',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('دڵنیام'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex: _bottomNavIndex,
        activeColor: Colors.white,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.verySmoothEdge,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        backgroundColor: const Color(0xFFFFD700),
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => CompanyProfile(),
                ),
              );
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
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height / 4,
          child: Container(
            alignment: Alignment.topRight,
            color: const Color(0xFF252526),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text(
                    "کرێدت ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    ": ${_userDetails?.credit.toString()} ",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height / 2,
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                Container(
                    width: 300,
                    padding: const EdgeInsets.only(top: 40),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                      ),
                      onPressed: () async {
                        // Fetch user data to get the userRole
                        try {
                          DocumentSnapshot userSnapshot =
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(_user!.uid)
                                  .get();

                          String userRole = userSnapshot['userRole'];

                          if (userRole == 'admin') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminScreen(),
                              ),
                            );
                          } else {
                            // ignore: use_build_context_synchronously
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('تۆ ئادمین نیت'),
                                  content: const Text(
                                      'بەم هۆکارە ناتوانی هیچ کارێک بکەی'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Close'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        } catch (e) {
                          print('Error fetching user data: $e');
                        }
                      },
                      child: const Text(
                        "ئادمین",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    )),
                Container(
                  padding: const EdgeInsets.only(
                    right: 8,
                    top: 8,
                  ),
                  width: double.infinity,
                  child: const Text(
                    "دەربارە",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(
                    right: 8,
                    top: 8,
                  ),
                  width: double.infinity,
                  child: Text(_userDetails!.about),
                ),
                Container(
                  padding: const EdgeInsets.only(
                    right: 8,
                    top: 8,
                  ),
                  width: double.infinity,
                  child: const Text(
                    "سۆشیاڵ میدیاکانمان",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(
                    right: 8,
                    top: 8,
                  ),
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 30,
                          child: Icon(
                            Icons.facebook,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: const CircleAvatar(
                          backgroundColor: Colors.black,
                          radius: 30,
                          child: Icon(
                            Icons.music_note,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 30,
                          child: Icon(
                            Icons.dataset_linked,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: const CircleAvatar(
                          backgroundColor: Colors.pink,
                          radius: 30,
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height / 10,
          left: 15,
          right: 15,
          height: MediaQuery.of(context).size.height / 4,
          child: FutureBuilder<String?>(
            future: _getUsername(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final username = snapshot.data ?? 'N/A';
                print(snapshot.data);
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height,
                        width: 200,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(
                                  imagUrl,
                                ),
                                fit: BoxFit.cover)),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class UserDetails {
  final String displayName;
  final String email;
  final int credit;
  final String about;

  UserDetails({
    required this.displayName,
    required this.email,
    required this.credit,
    required this.about,
  });
}
