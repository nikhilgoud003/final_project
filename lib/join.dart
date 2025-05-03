import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Join extends StatefulWidget {
  const Join({super.key});

  @override
  State<Join> createState() => _JoinState();
}

class _JoinState extends State<Join> {
  Map<String, double> exchangeRates = {};
  final List<double> originalPrice = [];
  final List<double> amounts = [];
  final List<String> selectedCurrency = [];

  @override
  void initState() {
    super.initState();
    fetchExchangeRates();
  }

  Future<void> fetchExchangeRates() async {
    final apiKey = "3d4e398b39c7329689eed4417b8c078a";
    final url =
        "http://api.currencylayer.com/live?access_key=$apiKey&currencies=EUR,GBP,INR,AUD,CAD";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          exchangeRates = Map<String, double>.from(data['quotes']);
        });
      } else {
        throw Exception('Failed to load exchange rates');
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  void convertAmount(int index) {
    if (selectedCurrency[index] == "USD") {
      setState(() {
        amounts[index] = originalPrice[index];
      });
    } else {
      final rateKey = "USD${selectedCurrency[index]}";
      final rate = exchangeRates[rateKey] ?? 1.0;
      setState(() {
        amounts[index] = originalPrice[index] * rate;
      });
    }
  }

  String getTimeMessage(Timestamp timestamp) {
    final DateTime now = DateTime.now();
    final DateTime date = timestamp.toDate();
    final Duration difference = date.difference(now);

    if (difference.isNegative) {
      return "Expired";
    } else if (difference.inDays < 5) {
      return "More\n${difference.inDays} days\nto go";
    } else if (difference.inDays < 7) {
      return "Less than\na week\nto go";
    } else if (difference.inDays <= 30) {
      final weeks = (difference.inDays / 7).ceil();
      return "More\n$weeks week${weeks > 1 ? 's' : ''}\n to go";
    } else {
      return "Date is far in the future";
    }
  }

  Widget _buildHikeList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('hike').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error retrieving data'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final hikes = snapshot.data?.docs;

        if (hikes == null || hikes.isEmpty) {
          return const Center(child: Text('No Trips available'));
        }

        return ListView.builder(
          itemCount: hikes.length,
          itemBuilder: (BuildContext context, int index) {
            final hikeData = hikes[index].data() as Map<String, dynamic>;

            final title = (hikeData['title'] ?? 'Untitled Trip').toString();
            final startLocation = (hikeData['start'] ?? {}) as Map;
            final endLocation = (hikeData['end'] ?? {}) as Map;
            final timings = hikeData['timings'] ?? Timestamp.now();
            final amount = (hikeData['amount'] ?? 0).toDouble();

            if (originalPrice.length <= index) {
              originalPrice.add(amount);
              amounts.add(amount);
              selectedCurrency.add('USD');
            }

            return Card(
              color: Colors.white.withOpacity(0.95),
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                leading: Text(
                  getTimeMessage(timings),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                title: Text(
                  'title: $title',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Start Location: ${startLocation['city'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'End Location: ${endLocation['city'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Timings: ${timings.toDate().toString()}',
                      style: const TextStyle(fontSize: 14, color: Colors.green),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Amount:",
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "${amounts[index].toStringAsFixed(2)} ${selectedCurrency[index]}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: DropdownButton<String>(
                            value: selectedCurrency[index],
                            isExpanded: true,
                            style: const TextStyle(color: Colors.red),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedCurrency[index] = value;
                                  convertAmount(index);
                                });
                              }
                            },
                            items: (["USD"] +
                                    exchangeRates.keys
                                        .map((key) => key.substring(3))
                                        .toList())
                                .map((currency) => DropdownMenuItem(
                                      value: currency,
                                      child: Text(currency),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Trip')),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/splash.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          _buildHikeList(),
        ],
      ),
    );
  }
}
