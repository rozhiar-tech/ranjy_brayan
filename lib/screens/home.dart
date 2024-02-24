import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:http/http.dart' as http;
import 'package:ranjy_brayan/screens/hotel_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bottomNavIndex = 0;
  bool isLoading = true;
  String? userName;

  List<IconData> iconList = [
    Icons.home,
    Icons.search,
    Icons.favorite,
    Icons.settings,
  ];

  List<dynamic> hotelsData = [];

  void fetchData() async {
    final url = Uri.parse('https://api.makcorps.com/city');
    final params = {
      'cityid': '60763',
      'pagination': '1',
      'cur': 'USD',
      'rooms': '1',
      'adults': '2',
      'checkin': '2024-02-25',
      'checkout': '2024-03-25',
      'api_key': '65d91a566a00880535251927',
    };

    try {
      final response = await http.get(url.replace(queryParameters: params));

      if (response.statusCode == 200) {
        setState(() {
          hotelsData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        print('Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        isLoading = false;
      }
    } catch (error) {
      print('Exception: $error');
      isLoading = false;
    }
  }

  Future<void> checkSignedInUser() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is signed in, retrieve their name from Firestore
      try {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        setState(() {
          userName = userSnapshot['firstName'];
        });
      } catch (e) {
        print('Error retrieving user data: $e');
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
    checkSignedInUser();
  }

  void changePage(index) {
    switch (index) {
      case 1:
        break;
      default:
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage('assets/user.png'),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    "بەخێربێیت $userName",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notification_add))
                ],
              ),
              const SizedBox(
                  height: 16), // Add spacing between the Row and the Buttons
              SizedBox(
                width: 350,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle location filter
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft:
                            Radius.circular(12), // Adjust the top left corner
                        bottomLeft: Radius.circular(
                            12), // Adjust the bottom left corner
                        topRight:
                            Radius.circular(12), // Adjust the top right corner
                        bottomRight: Radius.circular(
                            12), // Adjust the bottom right corner
                      ),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.search),
                          SizedBox(width: 8),
                          Text('ناوچە'),
                        ],
                      ),
                      Icon(Icons.filter_list),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),
              SizedBox(
                width: 350,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle date filter
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.date_range),
                      SizedBox(width: 8),
                      Text('کات'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),
              SizedBox(
                width: 350,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle guests filter
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft:
                            Radius.circular(12), // Adjust the top left corner
                        bottomLeft: Radius.circular(
                            12), // Adjust the bottom left corner
                        topRight:
                            Radius.circular(12), // Adjust the top right corner
                        bottomRight: Radius.circular(
                            12), // Adjust the bottom right corner
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.person), // User icon at the start
                          SizedBox(width: 8),
                          Text('میوان'),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              // Handle decrease action
                            },
                            icon: const Icon(Icons.remove),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                              '2'), // Display the current number of guests or fetch it dynamically
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: () {
                              // Handle increase action
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle guests filter
                },
                child: const Text('گەڕان'),
              ),
              const SizedBox(
                height: 25,
              ),
              isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount:
                            hotelsData.length - 1, // Exclude the last item
                        itemBuilder: (context, index) {
                          final hotel = hotelsData[index];
                          if (hotel is Map<String, dynamic>) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        HotelDetailsScreen(hotel: hotel),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 3,
                                margin: const EdgeInsets.all(8),
                                child: Column(
                                  children: [
                                    Image.network(
                                      'https://media.istockphoto.com/id/104731717/photo/luxury-resort.jpg?s=612x612&w=0&k=20&c=cODMSPbYyrn1FHake1xYz9M8r15iOfGz9Aosy9Db7mI=',
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            hotel['name'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(hotel['telephone'] ?? ''),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Text(
                                                'Rating: ',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                hotel['reviews']['rating']
                                                    .toString(),
                                                style: const TextStyle(
                                                    color: Colors.yellow),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons:
            iconList, // Make sure iconList is defined or replace it with your icon list
        activeIndex: _bottomNavIndex,
        activeColor: Colors.yellow,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.verySmoothEdge,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: (index) => setState(() => _bottomNavIndex = index),
      ),
    );
  }
}
