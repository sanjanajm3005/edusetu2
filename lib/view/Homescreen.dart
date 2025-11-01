import 'package:ai_edu_app/view/HomePageBottom.dart';
import 'package:ai_edu_app/view/SettingPage1.dart';
import 'package:ai_edu_app/view/ThemePrivider.dart';
import 'package:ai_edu_app/view/TopicProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => HomescreenState();
}

class HomescreenState extends State<Homescreen> {
  String userName = "Student";
  int selectedIndex = 0;

  void onPageChanged(int index) {
    setState(() => selectedIndex = index);
  }

  @override
  void initState() {
    super.initState();
    _loadSavedSubject();
  }

  Future<void> _loadSavedSubject() async {
    final prefs = await SharedPreferences.getInstance();
    final provider = context.read<TopicProvider>();
    final subject = prefs.getString('selectedSubject') ?? "";
    final topic = prefs.getString('selectedTopic') ?? "";
    if (subject.isNotEmpty) provider.setSubject(subject);
    if (topic.isNotEmpty) provider.setTopic(topic);
  }

  @override
  Widget build(BuildContext context) {
    final topicProvider = context.watch<TopicProvider>();
    final selectedSubject = topicProvider.selectedSubject;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ThemeManager.secondaryColor,
      body: Column(
        children: [
          // -------- TOP HEADER --------
          Container(
            width: double.infinity,
            height: screenHeight * 0.20,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.03,
            ),
            decoration: BoxDecoration(
              color: ThemeManager.primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  CircleAvatar(
                    backgroundColor: const Color.fromARGB(94, 158, 161, 187),
                    child: Lottie.asset('assets/animations/Graduation.json',
                        width: screenWidth * 0.08, height: screenWidth * 0.08),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Text("eduSetu",
                      style: GoogleFonts.fredoka(
                          color: const Color.fromARGB(255, 57, 34, 73),
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.065)),
                ]),
                SizedBox(height: screenHeight * 0.015),
                Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Hi, $userName 👋",
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: screenWidth * 0.055)),
                        if (selectedSubject.isNotEmpty)
                          Text("📘 Subject: $selectedSubject",
                              style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: screenWidth * 0.038)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings,
                        color: Color(0xFF22223b), size: 26),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    ),
                  )
                ]),
              ],
            ),
          ),

          // -------- MAIN CONTENT --------
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              child: Container(
                color: Colors.white,
                child: HomePageBottom(onPageChanged: onPageChanged),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
