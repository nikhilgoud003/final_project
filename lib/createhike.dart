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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Trip'),
        backgroundColor: Colors.blue[800],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/home.jpg'),
              fit: BoxFit.cover,
            )),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Location Selection Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _pickLocation(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Start Location'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _pickLocation(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('End Location'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Location Cards
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Card(
                        color: const Color.fromARGB(255, 10, 9, 9)
                            .withOpacity(0.85),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Start Location:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              const SizedBox(height: 4),
                              ..._buildAddressLines(startLocation),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Card(
                        color: const Color.fromARGB(255, 9, 8, 8)
                            .withOpacity(0.85),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('End Location:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              const SizedBox(height: 4),
                              ..._buildAddressLines(endLocation),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Date and Input Fields
                Card(
                  color:
                      const Color.fromARGB(255, 10, 10, 10).withOpacity(0.85),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Date:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            ElevatedButton(
                              onPressed: _pickDate,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                foregroundColor:
                                    const Color.fromARGB(255, 2, 2, 2),
                              ),
                              child: Text(
                                date == null
                                    ? 'Select Date'
                                    : '${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: "Hike Name",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: amountController,
                          decoration: const InputDecoration(
                            labelText: "Amount (\$USD)",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            isDense: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: const Color.fromARGB(255, 7, 6, 6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'SUBMIT',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAddressLines(Map<String, String>? location) {
    if (location == null || location.isEmpty) {
      return [
        const Text('Not selected',
            style: TextStyle(color: Colors.grey, fontSize: 12))
      ];
    }

    // Show only the most important address components to save space
    final importantKeys = [
      'road',
      'house_number',
      'city',
      'state',
      'postcode',
      'country'
    ];

    return importantKeys
        .where((key) => location.containsKey(key))
        .map((key) => Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: Text(
                '${key.replaceAll('_', ' ')}: ${location[key]}',
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ))
        .toList();
  }

  Future<void> _pickLocation(bool isStart) async {
    final address = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => _buildLocationPicker()),
    );

    if (address != null) {
      setState(() {
        if (isStart) {
          startLocation = jsonToMap(address).cast<String, String>();
        } else {
          endLocation = jsonToMap(address).cast<String, String>();
        }
      });
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        date = pickedDate;
      });
    }
  }

  Widget _buildLocationPicker() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Picker'),
        backgroundColor: Colors.blue[800],
      ),
      body: OpenStreetMapSearchAndPick(
        hintText: 'Search Location',
        buttonColor: const Color.fromARGB(255, 32, 116, 200),
        buttonText: 'Set Location',
        onPicked: (pickedData) => Navigator.pop(context, pickedData.address),
      ),
    );
  }

  Future<void> _submitData() async {
    if (startLocation == null ||
        endLocation == null ||
        date == null ||
        titleController.text.isEmpty ||
        amountController.text.isEmpty) {
      showAlert(
          context, 'Pending Information', 'Complete all the fields', () {});
      return;
    }

    try {
      await _reference.add({
        'title': titleController.text,
        'start': startLocation,
        'end': endLocation,
        'timings': date,
        'amount': num.parse(amountController.text),
      });

      showAlert(context, 'Confirmation', 'Created Hike!!!', () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Group()),
        );
      });

      setState(() {
        startLocation = {};
        endLocation = {};
        date = null;
        titleController.clear();
        amountController.clear();
      });
    } catch (error) {
      showAlert(context, 'Error', 'Failed to create hike: $error', () {});
    }
  }
}
