import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String _currentLocale = "id_ID";

  final List<String> _availableLocales = [
    "id_ID", // Indonesia
    "en_US", // English
    "fr_FR", // French
  ];

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentLocale = prefs.getString("locale") ?? "id_ID";
    });
  }

  Future<void> _updateLocale(String locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("locale", locale);
    setState(() {
      _currentLocale = locale;
    });

    Intl.defaultLocale = locale;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(title: const Text("User Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pilih Bahasa/Locale",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: _currentLocale,
              items:
                  _availableLocales
                      .map(
                        (locale) => DropdownMenuItem(
                          value: locale,
                          child: Text(locale),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                if (value != null) {
                  _updateLocale(value);
                }
              },
            ),
            const SizedBox(height: 20),
            Text(
              "Contoh format tanggal:",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat.yMMMMEEEEd(_currentLocale).format(DateTime.now()),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
