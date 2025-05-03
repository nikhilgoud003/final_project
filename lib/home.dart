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
  // Firestore collections
  final CollectionReference _atlPlaces =
      FirebaseFirestore.instance.collection('atl_places');
  final CollectionReference _otherPlaces =
      FirebaseFirestore.instance.collection('places');
  final CollectionReference _cultural =
      FirebaseFirestore.instance.collection('cultural');

  // Default placeholder image
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

  