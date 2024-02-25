import 'package:flutter/material.dart';
import 'package:ranjy_brayan/screens/hotel_details_screen.dart';

class SearchResultScreen extends StatelessWidget {
  final List<dynamic> hotels;

  SearchResultScreen({required this.hotels});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بەرهەمی گەرانت'),
      ),
      body: ListView.builder(
        itemCount: hotels.length,
        itemBuilder: (context, index) {
          final hotel = hotels[index];
          // Implement the UI to display each hotel in the search results
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HotelDetailsScreen(hotel: hotel),
                ),
              );
            },
            child: ListTile(
              leading: Image.network(
                hotel['photo1'] ?? '', // Update with your photo field
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(hotel['hotel_name'] ?? ''),
              subtitle: Text(hotel['addressline1'] ?? ''),
              // Add more details as needed
            ),
          );
        },
      ),
    );
  }
}
