import 'package:flutter/material.dart';
import 'description.dart';
import 'group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:carousel_slider/carousel_slider.dart';

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  final CollectionReference _atlPlaces =
      FirebaseFirestore.instance.collection('atl_places');
  final CollectionReference _otherPlaces =
      FirebaseFirestore.instance.collection('places');
  final CollectionReference _cultural =
      FirebaseFirestore.instance.collection('cultural');

  final String placeholderImage =
      'https://via.placeholder.com/500x300?text=Image+Not+Available';

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location error: ${e.toString()}')),
        );
      }
    }
  }

  String _formatPlaceName(String name) {
    if (name.isEmpty) return 'Unnamed Location';
    return name
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }

  Widget _buildNetworkImage(String url,
      {double height = 200, double width = double.infinity}) {
    return Image.network(
      url.isNotEmpty ? url : placeholderImage,
      fit: BoxFit.cover,
      height: height,
      width: width,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) =>
          _buildPlaceholderImage(height: height, width: width),
    );
  }

  Widget _buildPlaceholderImage(
      {double height = 200, double width = double.infinity}) {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[300],
      child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
    );
  }

  Widget _buildPlaceCard({
    required String imageUrl,
    required String name,
    required VoidCallback onTap,
    double height = 200,
    double width = double.infinity,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildNetworkImage(imageUrl, height: height, width: width),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  _formatPlaceName(name),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlacesList(CollectionReference collection,
      {bool isHorizontal = false}) {
    return SizedBox(
      height: isHorizontal ? 200 : 300,
      child: StreamBuilder<QuerySnapshot>(
        stream: collection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No places found in ${collection.id}'));
          }

          return ListView.builder(
            scrollDirection: isHorizontal ? Axis.horizontal : Axis.vertical,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return _buildPlaceCard(
                imageUrl: data['image']?.toString() ?? '',
                name: data['index']?.toString() ?? 'Unnamed Place',
                height: isHorizontal ? 180 : 200,
                width: isHorizontal ? 150 : double.infinity,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Description(
                        imageUrl: data['image']?.toString() ?? placeholderImage,
                        placeName:
                            _formatPlaceName(data['index']?.toString() ?? ''),
                        description: data['description']?.toString() ??
                            'No description available',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOtherPlacesCarousel() {
    return SizedBox(
      height: 300,
      child: StreamBuilder<QuerySnapshot>(
        stream: _otherPlaces.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No other places found'));
          }

          return CarouselSlider(
            options: CarouselOptions(
              height: 300,
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.9,
            ),
            items: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _buildPlaceCard(
                imageUrl: data['image']?.toString() ?? '',
                name: data['index']?.toString() ?? 'Unnamed Place',
                height: 280,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Description(
                        imageUrl: data['image']?.toString() ?? placeholderImage,
                        placeName:
                            _formatPlaceName(data['index']?.toString() ?? ''),
                        description: data['description']?.toString() ??
                            'No description available',
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ready for Adventure!!!'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.blue[800],
                image: const DecorationImage(
                  image: AssetImage('assets/background.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black54,
                    BlendMode.darken,
                  ),
                ),
              ),
              child: const Center(
                child: Text(
                  "Discover the Adventurer in YOU!!!",
                  style: TextStyle(
                    color: Color.fromARGB(255, 180, 208, 38),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black,
                        offset: Offset(2, 2),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Explore the places of the world',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Places Near Atlanta',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildPlacesList(_atlPlaces),
                  const SizedBox(height: 24),
                  const Text(
                    'Other Places & Destinations',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildOtherPlacesCarousel(),
                  const SizedBox(height: 24),
                  const Text(
                    'Cultural Diversity',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildPlacesList(_cultural, isHorizontal: true),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home, size: 30),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.explore, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Group()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
