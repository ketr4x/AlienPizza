import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MainBody extends StatefulWidget {
  const MainBody({super.key});

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
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/api/toppings'));
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
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            children: List.generate(checkboxData.length, (index) {
              return Card(
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
              );
            }),
          ),
        ),
      ],
    );
  }
}

class CheckboxItem {
  bool isChecked;
  String label;

  CheckboxItem({required this.isChecked, required this.label});
}