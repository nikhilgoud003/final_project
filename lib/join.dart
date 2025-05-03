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
