import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, this.onThemeChanged});
  final VoidCallback? onThemeChanged;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _toppingsController = TextEditingController();
  Color _selectedColor = Colors.lightBlue;
  bool _soundEnabled = true;

  Future<void> setConfig(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getConfig(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  @override
  void initState() {
    super.initState();
    _loadToppingsCount();
    _loadThemeColor();
    _loadSoundPreference();
  }

  Future<void> _loadToppingsCount() async {
    final count = await getConfig('toppings_count');
    setState(() {
      _toppingsController.text = count ?? '14';
    });
  }

  Future<void> _loadThemeColor() async {
    final colorValue = await getConfig('theme_color');
    if (colorValue != null) {
      setState(() {
        _selectedColor = Color(int.parse(colorValue, radix: 16));
      });
    }
  }

  Future<void> _loadSoundPreference() async {
    final soundEnabled = await getConfig('sound_enabled');
    if (soundEnabled == null) {
      // Set default to true if not set
      await setConfig('sound_enabled', 'true');
      setState(() {
        _soundEnabled = true;
      });
    } else {
      setState(() {
        _soundEnabled = soundEnabled != 'false';
      });
    }
  }

  Future<void> _showColorPicker() async {
    await ColorPicker(
      color: _selectedColor,
      onColorChanged: (Color color) async {
        setState(() {
          _selectedColor = color;
        });
        final argb = color.toARGB32();
        await setConfig('theme_color', argb.toRadixString(16).padLeft(8, '0'));
      },
      heading: Text(
        'Select theme color',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subheading: Text(
        'Select color shade',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
        ColorPickerType.wheel: true,
      },
    ).showPickerDialog(
      context,
      constraints: const BoxConstraints(
          minHeight: 460, minWidth: 300, maxWidth: 320),
    );

    // Update theme immediately after dialog closes
    widget.onThemeChanged?.call();
  }

  @override
  void dispose() {
    _toppingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            ListTile(
              title: const Text('Theme Color'),
              subtitle: const Text('Tap to change the app theme color'),
              trailing: Container(
                width: 100,
                height: 40,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
              ),
              onTap: _showColorPicker,
            ),
            ListTile(
              title: Text('Toppings number'),
              trailing: SizedBox(
                width: 150,
                child: TextField(
                  controller: _toppingsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter number',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    final number = int.tryParse(value);
                    if (number != null) {
                      setConfig('toppings_count', value);
                    }
                  },
                ),
              ),
            ),
            SwitchListTile(
              title: const Text('Sound Effects'),
              subtitle: const Text('Enable or disable sound effects'),
              value: _soundEnabled,
              onChanged: (bool value) async {
                setState(() {
                  _soundEnabled = value;
                });
                await setConfig('sound_enabled', value.toString());
              },
            ),
          ],
        ),
      ),
    );
  }
}