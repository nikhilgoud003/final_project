import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class JourneyDetails extends StatefulWidget {
  final String title;
  final startLocation;
  final endLocation;
  // ignore: prefer_typing_uninitialized_variables
  final timings;
  final double amount; // Default in USD
  // ignore: prefer_typing_uninitialized_variables
  final id;

  const JourneyDetails({
    super.key,
    required this.amount,
    required this.title,
    required this.startLocation,
    required this.endLocation,
    required this.timings,
    required this.id,
  });

  @override
  // ignore: library_private_types_in_public_api
  _JourneyDetailsState createState() => _JourneyDetailsState();
}

class _JourneyDetailsState extends State<JourneyDetails> {
  String selectedCurrency = "USD";
  Map<String, double> exchangeRates = {};
  double convertedAmount = 0.0;

  @override
  void initState() {
    super.initState();
    convertedAmount = widget.amount;
    fetchExchangeRates();
  }

  Future<void> fetchExchangeRates() async {
    final apiKey = "YOUR_CURRENCY_LAYER_API_KEY"; // Replace with your API key
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

  void convertAmount() {
    if (selectedCurrency == "USD") {
      setState(() {
        convertedAmount = widget.amount;
      });
    } else {
      final rateKey = "USD$selectedCurrency";
      final rate = exchangeRates[rateKey] ?? 1.0;
      setState(() {
        convertedAmount = widget.amount * rate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Source: ${widget.startLocation['city']}",
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text("Destination: ${widget.endLocation['city']}",
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text("Start Time: ${widget.timings.toDate().toString()}",
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Round Trip Amount:", style: TextStyle(fontSize: 18)),
                Text(
                  "${convertedAmount.toStringAsFixed(2)} $selectedCurrency",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedCurrency,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCurrency = value;
                    convertAmount();
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
          ],
        ),
      ),
    );
  }
}
