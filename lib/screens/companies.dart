import 'dart:io';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ranjy_brayan/screens/CompanyDetailsScreen.dart';
import 'package:ranjy_brayan/screens/companyProfile.dart';
import 'package:ranjy_brayan/screens/home.dart';
import 'package:ranjy_brayan/screens/profile.dart';

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({Key? key}) : super(key: key);

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  int _bottomNavIndex = 2;
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkSignedInUser();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF252526),
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
              break;
            case 3:
              // Settings or other page
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
        title: const Text('Companies'),
      ),
      body: FutureBuilder(
        future: _getCompanies(),
        builder: (context, AsyncSnapshot<List<Company>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No companies available.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Company company = snapshot.data![index];
                return _buildCompanyCard(context, company);
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Company>> _getCompanies() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('companies').get();

      List<Company> companies = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Company(
          imageUrl: data['imageUrl'] ?? '',
          name: data['name'] ?? '',
          offers: List<String>.from(data['offers'] ?? []),
        );
      }).toList();

      return companies;
    } catch (e) {
      throw 'Error fetching companies: $e';
    }
  }

  Widget _buildCompanyCard(BuildContext context, Company company) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 3,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CompanyDetailsScreen(company: company),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              company.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Offers: ${company.offers.join(', ')}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Company {
  final String imageUrl;
  final String name;
  final List<String> offers;

  Company({required this.imageUrl, required this.name, required this.offers});
}
