import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'page2.dart';
import 'settings.dart';

class MainBody extends StatefulWidget {
  final String title;
  const MainBody({super.key, required this.title, required this.onThemeChanged});
  final VoidCallback onThemeChanged;

  @override
  State<MainBody> createState() => _MainBodyState();
}

class _MainBodyState extends State<MainBody> {
  Map<int, CheckboxItem> checkboxData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchToppings();
  }

  Future<void> fetchToppings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final toppingsCount = prefs.getString('toppings_count') ?? '14';
      final response = await http.get(
        Uri.parse('https://alien-pizza-28ebb921ad43.herokuapp.com/api/toppings?count=$toppingsCount')
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
        print(e);
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateToScreen2() async {
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(onThemeChanged: widget.onThemeChanged),
                  ),
                );
                fetchToppings();
              },
            ),
          ],
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(onThemeChanged: widget.onThemeChanged),
                ),
              );
              fetchToppings();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),


        Image.asset(
          'assets/images/alien_pizza.png',
          width: 250,
        ),

        const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Select your pizza toppings!',
              style: Theme
                  .of(context)
                  .textTheme
                  .headlineSmall,
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 2,
              padding: const EdgeInsets.all(8.0),
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              children: List.generate(checkboxData.length, (index) {
                return Card(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (checkboxData[index] != null) {
                          checkboxData[index]!.isChecked =
                          !checkboxData[index]!.isChecked;
                        }
                      });
                    },
                    child: Row(
                      children: [
                        Checkbox(
                          value: checkboxData[index]?.isChecked ?? false,
                          onChanged: (value) {
                            setState(() {
                              if (checkboxData[index] != null) {
                                checkboxData[index]!.isChecked = value ?? false;
                              }
                            });
                          },
                        ),
                        Expanded(
                          child: Text(checkboxData[index]?.label ?? ''),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'refresh',
            onPressed: fetchToppings,
            child: const Icon(Icons.refresh),
          ),
          if (checkboxData.values.any((item) => item.isChecked)) ...[
            const SizedBox(width: 12),
            FloatingActionButton(
              heroTag: 'forward',
              onPressed: _navigateToScreen2,
              child: const Icon(Icons.arrow_forward),
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

  CheckboxItem({required this.isChecked, required this.label});
}
