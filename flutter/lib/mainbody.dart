import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'page2.dart';
import 'settings.dart';

class MainBody extends StatefulWidget {
  final String title;
  final VoidCallback onThemeChanged;

  const MainBody({
    super.key,
    required this.title,
    required this.onThemeChanged,
  });

  @override
  State<MainBody> createState() => _MainBodyState();
}

class _MainBodyState extends State<MainBody> {
  static const double _imageWidth = 280.0;
  static const int _gridCrossAxisCount = 2;
  static const double _gridChildAspectRatio = 2.2;
  static const double _fabSpacing = 12.0;

  Map<int, CheckboxItem> checkboxData = {};
  bool isLoading = true;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    fetchToppings();
    _playBackgroundMusic();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playBackgroundMusic() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final soundEnabled = prefs.getString('sound_enabled');

      if (soundEnabled == null || soundEnabled != 'false') {
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.play(AssetSource('mainmusic.mp3'));
      } else {
        await _audioPlayer.stop();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error playing background music: $e');
      }
    }
  }

  Future<void> fetchToppings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final toppingsCount = prefs.getString('toppings_count') ?? '14';
      final response = await http.get(
        Uri.parse(
          'https://alien-pizza-28ebb921ad43.herokuapp.com/api/toppings?count=$toppingsCount',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<String> toppings = List<String>.from(data['toppings']);

        setState(() {
          checkboxData = {
            for (int i = 0; i < toppings.length; i++)
              i: CheckboxItem(isChecked: false, label: toppings[i])
          };
          isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching toppings: $e');
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _navigateToScreen2() async {
    final selectedToppings = checkboxData.values
        .where((item) => item.isChecked)
        .map((item) => item.label)
        .toList();

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Alien Pizza Evaluation'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: Screen2(selectedToppings: selectedToppings),
        ),
      ),
    );

    await fetchToppings();
  }

  Future<void> _navigateToSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          onThemeChanged: widget.onThemeChanged,
        ),
      ),
    );
    fetchToppings();
    _playBackgroundMusic();
  }

  Widget _buildToppingCard(int index) {
    final isChecked = checkboxData[index]?.isChecked ?? false;

    return Card(
      elevation: isChecked ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isChecked
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            if (checkboxData[index] != null) {
              checkboxData[index]!.isChecked = !checkboxData[index]!.isChecked;
            }
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: [
              Checkbox(
                value: isChecked,
                onChanged: (value) {
                  setState(() {
                    if (checkboxData[index] != null) {
                      checkboxData[index]!.isChecked = value ?? false;
                    }
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: Text(
                  checkboxData[index]?.label ?? '',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        isChecked ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _navigateToSettings,
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                'Loading toppings...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    final selectedCount = checkboxData.values
        .where((item) => item.isChecked)
        .length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.inversePrimary,
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Hero(
                    tag: 'pizza_logo',
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/alien_pizza.png',
                        width: _imageWidth,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Select Your Pizza Toppings',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (selectedCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$selectedCount topping${selectedCount != 1 ? 's' : ''} selected',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: _gridCrossAxisCount,
                childAspectRatio: _gridChildAspectRatio,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                children: List.generate(
                  checkboxData.length,
                  (index) => _buildToppingCard(index),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'refresh',
            onPressed: fetchToppings,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            tooltip: 'Get new toppings',
          ),
          if (selectedCount > 0) ...[
            const SizedBox(width: _fabSpacing),
            FloatingActionButton.extended(
              heroTag: 'forward',
              onPressed: _navigateToScreen2,
              icon: const Icon(Icons.restaurant),
              label: const Text('Evaluate'),
              tooltip: 'Evaluate pizza',
            ),
          ],
        ],
      ),
    );
  }
}

class CheckboxItem {
  bool isChecked;
  String label;

  CheckboxItem({
    required this.isChecked,
    required this.label,
  });
}
