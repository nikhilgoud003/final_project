import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';
import 'package:floating_bubbles/floating_bubbles.dart';
import 'group.dart';
import 'helpers.dart';

class CreateHike extends StatefulWidget {
  const CreateHike({Key? key}) : super(key: key);

  @override
  State<CreateHike> createState() => _CreateHikeState();
}

class _CreateHikeState extends State<CreateHike> {
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('hike');
  Map<String, String>? startLocation = {};
  Map<String, String>? endLocation = {};
  TextEditingController titleController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  DateTime? date;

  Map<String, dynamic> jsonToMap(dynamic jsonType) {
    if (jsonType is Map<String, dynamic>) {
      return jsonType;
    } else if (jsonType is String) {
      return Map<String, dynamic>.from(jsonDecode(jsonType));
    } else {
      throw Exception("Unsupported type for conversion to Map");
    }
  }

