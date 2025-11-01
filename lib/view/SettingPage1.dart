import 'package:ai_edu_app/view/ThemePrivider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String selectedTheme = "Purple";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: ThemeManager.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Theme",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 15),
            DropdownButton<String>(
              value: selectedTheme,
              items: const [
                DropdownMenuItem(value: "Purple", child: Text("Focus Purple")),
                DropdownMenuItem(value: "Blue", child: Text("Calm Sky")),
                DropdownMenuItem(value: "Green", child: Text("Growth Green")),
                DropdownMenuItem(value: "Yellow", child: Text("Bright Mind")),
                DropdownMenuItem(value: "Orange", child: Text("Inspire Orange")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedTheme = value!;
                  ThemeManager.setTheme(selectedTheme);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
