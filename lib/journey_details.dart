import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class JourneyDetails extends StatefulWidget {
  final String title;
  final dynamic startLocation;
  final dynamic endLocation;
  final dynamic timings;
  final double amount;
  final dynamic id;

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
    final apiKey = "YOUR_CURRENCY_LAYER_API_KEY";
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
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("Destination: ${widget.endLocation['city']}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("Start Time: ${widget.timings.toDate().toString()}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Round Trip Amount:",
                    style: TextStyle(fontSize: 18)),
                Text(
                  "${convertedAmount.toStringAsFixed(2)} $selectedCurrency",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
