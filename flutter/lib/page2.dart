import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playSound();
    _evaluatePizza(widget.selectedToppings);
  }

  Future<void> _playSound() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final soundEnabled = prefs.getString('sound_enabled');

      if (soundEnabled == null || soundEnabled != 'false') {
        await _audioPlayer.play(AssetSource('spacesound.mp3'));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error playing sound: $e');
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _evaluatePizza(List<String> toppings) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _pizzaData = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://alien-pizza-28ebb921ad43.herokuapp.com/api/evaluate'),
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_isLoading)
          Center(child: const CircularProgressIndicator())
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
                      const Text('Rating: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('${_pizzaData!['rating']}/100', style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Backstory:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
