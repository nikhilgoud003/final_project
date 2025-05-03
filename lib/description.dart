import 'package:flutter/material.dart';
import 'group.dart';
import 'home.dart';

class Description extends StatelessWidget {
  final String imageUrl;
  final String placeName;
  final String description;

  const Description({
    super.key,
    required this.imageUrl,
    required this.placeName,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Description"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 600,
              width: double.infinity,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '👇🏻👇🏻👇🏻👇🏻👇🏻👇🏻👇🏻👇🏻👇🏻👇🏻👇🏻👇🏻👇🏻👇🏻👇🏻👇🏻\n\n$description',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              color: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyHome()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.navigation),
              color: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Group()),
                );
              },
            ),
            // IconButton(
            //   icon: const Icon(
            //     Icons.camera_alt,
            //     color: Colors.white,
            //   ),
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => const Capture()),
            //     );
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
