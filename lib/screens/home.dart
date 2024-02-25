import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:ranjy_brayan/screens/SearchResultScreen.dart';
import 'package:ranjy_brayan/screens/companies.dart';
import 'package:ranjy_brayan/screens/hotel_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ranjy_brayan/screens/profile.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bottomNavIndex = 0;
  bool isLoading = true;
  String? userName;
  String? userRole;
  List<String> countries = [
    "ناوچە",
    "Afghanistan",
    "Albania",
    "Algeria",
    "Andorra",
    "Angola",
    "Anguilla",
    "Antigua &amp; Barbuda",
    "Argentina",
    "Armenia",
    "Aruba",
    "Australia",
    "Austria",
    "Azerbaijan",
    "Bahamas",
    "Bahrain",
    "Bangladesh",
    "Barbados",
    "Belarus",
    "Belgium",
    "Belize",
    "Benin",
    "Bermuda",
    "Bhutan",
    "Bolivia",
    "Bosnia &amp; Herzegovina",
    "Botswana",
    "Brazil",
    "British Virgin Islands",
    "Brunei",
    "Bulgaria",
    "Burkina Faso",
    "Burundi",
    "Cambodia",
    "Cameroon",
    "Cape Verde",
    "Cayman Islands",
    "Chad",
    "Chile",
    "China",
    "Colombia",
    "Congo",
    "Cook Islands",
    "Costa Rica",
    "Cote D Ivoire",
    "Croatia",
    "Cruise Ship",
    "Cuba",
    "Cyprus",
    "Czech Republic",
    "Denmark",
    "Djibouti",
    "Dominica",
    "Dominican Republic",
    "Ecuador",
    "Egypt",
    "El Salvador",
    "Equatorial Guinea",
    "Estonia",
    "Ethiopia",
    "Falkland Islands",
    "Faroe Islands",
    "Fiji",
    "Finland",
    "France",
    "French Polynesia",
    "French West Indies",
    "Gabon",
    "Gambia",
    "Georgia",
    "Germany",
    "Ghana",
    "Gibraltar",
    "Greece",
    "Greenland",
    "Grenada",
    "Guam",
    "Guatemala",
    "Guernsey",
    "Guinea",
    "Guinea Bissau",
    "Guyana",
    "Haiti",
    "Honduras",
    "Hong Kong",
    "Hungary",
    "Iceland",
    "India",
    "Indonesia",
    "Iran",
    "Iraq",
    "Ireland",
    "Isle of Man",
    "Israel",
    "Italy",
    "Jamaica",
    "Japan",
    "Jersey",
    "Jordan",
    "Kazakhstan",
    "Kenya",
    "Kuwait",
    "Kyrgyz Republic",
    "Laos",
    "Latvia",
    "Lebanon",
    "Lesotho",
    "Liberia",
    "Libya",
    "Liechtenstein",
    "Lithuania",
    "Luxembourg",
    "Macau",
    "Macedonia",
    "Madagascar",
    "Malawi",
    "Malaysia",
    "Maldives",
    "Mali",
    "Malta",
    "Mauritania",
    "Mauritius",
    "Mexico",
    "Moldova",
    "Monaco",
    "Mongolia",
    "Montenegro",
    "Montserrat",
    "Morocco",
    "Mozambique",
    "Namibia",
    "Nepal",
    "Netherlands",
    "Netherlands Antilles",
    "New Caledonia",
    "New Zealand",
    "Nicaragua",
    "Niger",
    "Nigeria",
    "Norway",
    "Oman",
    "Pakistan",
    "Palestine",
    "Panama",
    "Papua New Guinea",
    "Paraguay",
    "Peru",
    "Philippines",
    "Poland",
    "Portugal",
    "Puerto Rico",
    "Qatar",
    "Reunion",
    "Romania",
    "Russia",
    "Rwanda",
    "Saint Pierre &amp; Miquelon",
    "Samoa",
    "San Marino",
    "Satellite",
    "Saudi Arabia",
    "Senegal",
    "Serbia",
    "Seychelles",
    "Sierra Leone",
    "Singapore",
    "Slovakia",
    "Slovenia",
    "South Africa",
    "South Korea",
    "Spain",
    "Sri Lanka",
    "St Kitts &amp; Nevis",
    "St Lucia",
    "St Vincent",
    "St. Lucia",
    "Sudan",
    "Suriname",
    "Swaziland",
    "Sweden",
    "Switzerland",
    "Syria",
    "Taiwan",
    "Tajikistan",
    "Tanzania",
    "Thailand",
    "Timor L'Este",
    "Togo",
    "Tonga",
    "Trinidad &amp; Tobago",
    "Tunisia",
    "Turkey",
    "Turkmenistan",
    "Turks &amp; Caicos",
    "Uganda",
    "Ukraine",
    "United Arab Emirates",
    "United Kingdom",
    "Uruguay",
    "Uzbekistan",
    "Venezuela",
    "Vietnam",
    "Virgin Islands (US)",
    "Yemen",
    "Zambia",
    "Zimbabwe"
  ];
  DateTime? checkInDate;
  DateTime? checkOutDate;
  int numberOfGuests = 2; // Default value
  String selectedCountry = 'ناوچە';

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
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  List<dynamic> filterHotels(String selectedCountry) {
    // Replace this with your actual filtering logic
    List<dynamic> allHotels =
        hotelsData; // Replace with your data fetching logic

    // Filter hotels based on the selected country
    List<dynamic> filteredHotels = allHotels
        .where((hotel) => (hotel['country'] ?? '') == selectedCountry)
        .toList();

    return filteredHotels;
  }

  List<dynamic> hotelsData = [];
  void fetchData() async {
    try {
      String jsonString = await rootBundle.loadString('data/hotels.json');
      Map<String, dynamic> jsonData = json.decode(jsonString);

      // Extract the "hotels" list from the JSON data
      List<dynamic> hotels = jsonData['hotels'];

      setState(() {
        hotelsData = hotels;
        isLoading = false;
      });
    } catch (error) {
      print('Error loading data: $error');
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
          userRole = userSnapshot['userRole'];
        });
      } catch (e) {
        print('Error retrieving user data: $e');
      }
    }
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

  void showCountryPickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('شوێنی گەشتەکەت دیاری بکە'),
          content: DropdownButton<String>(
            value: selectedCountry,
            onChanged: (String? newValue) {
              setState(() {
                selectedCountry = newValue!;
              });
            },
            items: countries.map((String country) {
              return DropdownMenuItem<String>(
                value: country,
                child: Text(country),
              );
            }).toList(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('دڵنیام'),
            ),
          ],
        );
      },
    );
  }

  void showDatePickerDialog() async {
    DateTimeRange? pickedDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDateRange != null) {
      setState(() {
        checkInDate = pickedDateRange.start;
        checkOutDate = pickedDateRange.end;
      });
    }
  }

  void showGuestsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ژمارەی میوانەکان دیاری بکە'),
          content: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    if (numberOfGuests > 1) {
                      numberOfGuests--;
                    }
                  });
                },
                icon: const Icon(Icons.remove),
              ),
              Text(numberOfGuests.toString()),
              IconButton(
                onPressed: () {
                  setState(() {
                    numberOfGuests++;
                  });
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('دڵنیام'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    checkSignedInUser();
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
              child: const Icon(Icons.message),
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
                    style: const TextStyle(
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
                    showCountryPickerDialog();
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.search),
                          const SizedBox(width: 8),
                          Text(selectedCountry),
                        ],
                      ),
                      const Icon(Icons.filter_list),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 350,
                child: ElevatedButton(
                  onPressed: () {
                    showDatePickerDialog();
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
                  child: Row(
                    children: [
                      const Icon(Icons.date_range),
                      const SizedBox(width: 8),
                      Text(checkInDate == null
                          ? 'کات'
                          : '${DateFormat.yMd().format(checkInDate!)} - ${DateFormat.yMd().format(checkOutDate!)}'),
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
                    showGuestsDialog();
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person),
                          SizedBox(width: 8),
                          Text('میوان - $numberOfGuests'),
                        ],
                      ),
                      Icon(Icons.add),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedCountry == 'ناوچە') {
                    return;
                  }
                  List<dynamic> filteredHotels = filterHotels(
                      selectedCountry); // Replace with your filtering logic
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SearchResultScreen(hotels: filteredHotels),
                    ),
                  );
                },
                child: const Text('گەڕان'),
              ),
              const SizedBox(
                height: 25,
              ),
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: hotelsData.length,
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
                                      hotel['photo1'] ??
                                          '', // Update with your photo field
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
                                            hotel['hotel_name'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(hotel['addressline1'] ?? ''),
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
                                                hotel['rating_average']
                                                        ?.toString() ??
                                                    '',
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
    );
  }
}
