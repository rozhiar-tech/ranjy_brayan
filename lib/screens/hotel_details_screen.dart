import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ranjy_brayan/screens/MoreDetailsScreen.dart';

class HotelDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> hotel;

  const HotelDetailsScreen({Key? key, required this.hotel}) : super(key: key);

  @override
  State<HotelDetailsScreen> createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends State<HotelDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    List<String> images = [
      widget.hotel['photo1'] ?? '',
      widget.hotel['photo2'] ?? '',
      widget.hotel['photo3'] ?? '',
      widget.hotel['photo4'] ?? '',
      widget.hotel['photo5'] ?? '',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.hotel['hotel_name'] ?? '',
          style: const TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.yellowAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 300.0,
                viewportFraction: 1.0,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.easeInOut,
                enlargeCenterPage: true,
              ),
              items: images.map((image) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.0),
                        image: DecorationImage(
                          image: NetworkImage(image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.hotel['overview'] ?? '',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MoreDetailsScreen(
                              overview: widget.hotel['overview'] ?? ''),
                        ),
                      );
                    },
                    child: const Text(
                      'Read more',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.yellow,
                        size: 30,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.hotel['addressline1']}, ${widget.hotel['city']},${widget.hotel['country']}',
                        overflow: TextOverflow.ellipsis,
                        maxLines:
                            2, 
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.date_range,
                        color: Colors.yellow,
                        size: 30,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Check-in: ${widget.hotel['checkin']}, Check-out: ${widget.hotel['checkout']}',
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Facilities',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 90),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FacilityCircle('Wi-Fi'),
                          FacilityCircle('Fitness Center'),
                          FacilityCircle('Sauna'),
                          FacilityCircle('Outdoor Pool'),
                          FacilityCircle('Spa'),
                          FacilityCircle('Massage'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: Text('Price: ${widget.hotel['rates_from'] ?? 'N/A'} USD'),
        icon: const Icon(Icons.attach_money_outlined),
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class FacilityCircle extends StatelessWidget {
  final String facility;

  FacilityCircle(this.facility);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      width: 70,
      height: 70,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.yellow,
      ),
      child: Center(
        child: Text(
          facility,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
