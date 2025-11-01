import 'package:ai_edu_app/view/ChooseTopic.dart';
import 'package:ai_edu_app/view/Homescreen.dart';
import 'package:ai_edu_app/view/TopicProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';


class ChooseSub extends StatelessWidget {
  const ChooseSub({super.key});

  @override
  Widget build(BuildContext context) {
    // List of subjects and their animations (same as before)
    List<Map<String, String>> subjects = [
      {"name": "Mathematics", "lottie": "assets/animations/Teacher of Mathematics.json"},
      {"name": "English", "lottie": "assets/animations/English.json"},
      {"name": "Physics", "lottie": "assets/animations/Physics simulation.json"},
      {"name": "Chemistry", "lottie": "assets/animations/chemistry.json"},
      {"name": "Biology", "lottie": "assets/animations/biology.json"},
      {"name": "Computer Science", "lottie": "assets/animations/cs.json"},
      {"name": "Geography", "lottie": "assets/animations/geography.json"},
      {"name": "History", "lottie": "assets/animations/history.json"},
      {"name": "Economics", "lottie": "assets/animations/economics.json"},
      {"name": "Civics", "lottie": "assets/animations/civics.json"},
      {"name": "Art", "lottie": "assets/animations/art.json"},
    ];

    // Card colors (unchanged)
    final List<Color> cardColors = [
      const Color.fromARGB(255, 207, 190, 231), // lavender
      const Color.fromARGB(255, 224, 193, 176), // peach
      const Color.fromARGB(255, 182, 230, 218), // mint
      const Color.fromARGB(255, 233, 191, 191), // blush
      const Color.fromARGB(255, 179, 196, 219), // baby blue
    ];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 233, 251),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Choose Subject",
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),

      // Subject List (unchanged visually)
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          final isEven = index % 2 == 0;
          final cardColor = cardColors[index % cardColors.length];

          return GestureDetector(
            onTap: () {
              // ✅ Save selected subject globally
              context.read<TopicProvider>().setSubject(subject["name"]!);

              // ✅ Move to topic selection screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChooseTopic(subject: subject["name"]!),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),

              // 👇 same UI (no changes)
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: isEven
                    ? [
                        Expanded(
                          child: Text(
                            subject["name"]!,
                            textAlign: TextAlign.left,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: Lottie.asset(
                            subject["lottie"]!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ]
                    : [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: Lottie.asset(
                            subject["lottie"]!,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            subject["name"]!,
                            textAlign: TextAlign.right,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
              ),
            ),
          );
        },
      ),
    );
  }
}
