import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Screen2 extends StatefulWidget {
  final List<String> selectedToppings;
  const Screen2({super.key, required this.selectedToppings});

  @override
  State<Screen2> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  bool _isLoading = false;
  Map<String, dynamic>? _pizzaData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _evaluatePizza(widget.selectedToppings);
  }

  Future<void> _evaluatePizza(List<String> toppings) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _pizzaData = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5000/api/evaluate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'toppings': toppings}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _pizzaData = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to evaluate pizza';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isLoading)
          const CircularProgressIndicator()
        else if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.red))
        else if (_pizzaData != null)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _pizzaData!['name'] ?? '',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Rating: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${_pizzaData!['rating']}/100', style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Backstory:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(_pizzaData!['backstory'] ?? ''),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
