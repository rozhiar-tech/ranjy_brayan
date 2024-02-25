import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ranjy_brayan/screens/CompanyDetailsScreen.dart';
import 'package:ranjy_brayan/screens/home.dart';
import 'package:ranjy_brayan/screens/profile.dart';

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({Key? key}) : super(key: key);

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  int _bottomNavIndex = 2;

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
              break;
            case 3:
              // Settings or other page
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
