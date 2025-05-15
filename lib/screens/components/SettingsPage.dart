import 'package:flutter/material.dart';


class MyApp {
  static ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool pushNotifications = false;
  bool emailUpdates = false;
  String theme = 'Light'; // Default theme

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications Section
            Text('Notifications', style: _sectionTitleStyle()),
            const SizedBox(height: 10),

            _buildSwitchTile(
              title: 'Push Notifications',
              subtitle: 'Receive alerts about air quality if AQI > 150.',
              value: pushNotifications,
              onChanged: (val) {
                setState(() => pushNotifications = val);
                if (val) {
                  _showSnackBar('Push Notifications Enabled');
                } else {
                  _showSnackBar('Push Notifications Disabled');
                }
              },
            ),

            _buildSwitchTile(
              title: 'Email Updates',
              subtitle: 'Get daily air quality reports if AQI > 150.',
              value: emailUpdates,
              onChanged: (val) {
                setState(() => emailUpdates = val);
                if (val) {
                  _showSnackBar('Email Updates Enabled');
                } else {
                  _showSnackBar('Email Updates Disabled');
                }
              },
            ),

            const SizedBox(height: 20),

            // Appearance Section
            Text('Appearance', style: _sectionTitleStyle()),
            const SizedBox(height: 10),

            // Theme Selector
            ListTile(
              title: const Text('Theme'),
              subtitle: const Text('Choose your preferred theme.'),
              trailing: DropdownButton<String>(
                value: theme,
                onChanged: (String? newValue) {
                  setState(() {
                    theme = newValue!;
                    // Update the global theme
                    if (theme == 'Light') {
                      MyApp.themeNotifier.value = ThemeMode.light;
                    } else {
                      MyApp.themeNotifier.value = ThemeMode.dark;
                    }
                  });
                  _showSnackBar('Theme changed to $theme');
                },
                items: ['Light', 'Dark'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 30),

            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _saveSettings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('Save Changes', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Switch Tiles
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  // Helper Method to Show SnackBar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Save Settings Method
  void _saveSettings() {
    // Simulate saving settings (e.g., to a database or shared preferences)
    _showSnackBar('Settings saved successfully!');
  }

  // Section Title Style
  TextStyle _sectionTitleStyle() => const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      );
}