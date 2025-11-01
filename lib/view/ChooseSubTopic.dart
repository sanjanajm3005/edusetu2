import 'package:ai_edu_app/controller/Gemini_Service.dart';
import 'package:ai_edu_app/view/Homescreen.dart';
import 'package:ai_edu_app/view/TopicProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChooseSubtopic extends StatefulWidget {
  final String subject;
  final String topic;

  const ChooseSubtopic({
    super.key,
    required this.subject,
    required this.topic,
  });

  @override
  State<ChooseSubtopic> createState() => _ChooseSubtopicState();
}

class _ChooseSubtopicState extends State<ChooseSubtopic> {
  List<String> subtopics = [];
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _fetchSubtopics();
  }

  Future<void> _fetchSubtopics() async {
    try {
      const apiKey = 'AIzaSyB9eidTJTU0VyErijXmdQZZ1Ec367Otg10';
      final gemini = GeminiService(apiKey: apiKey);

      final prompt = '''
List 6–10 important subtopics that come under "${widget.topic}" in the subject "${widget.subject}".
Return only subtopic names, separated by commas, without numbering or extra text.
''';

      final response = await gemini.askGemini(prompt);

      final fetched = response
          .split(RegExp(r'[,\n]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      setState(() {
        subtopics = fetched.isNotEmpty ? fetched : ["Overview", "Basics"];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        subtopics = ["Overview", "Basics"];
        isLoading = false;
        isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColors = [
      const Color.fromARGB(255, 207, 190, 231),
      const Color.fromARGB(255, 224, 193, 176),
      const Color.fromARGB(255, 182, 230, 218),
      const Color.fromARGB(255, 233, 191, 191),
      const Color.fromARGB(255, 179, 196, 219),
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
          "Choose Subtopic",
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.purple),
            )
          : isError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning, color: Colors.redAccent, size: 60),
                      const SizedBox(height: 12),
                      Text(
                        "Failed to load subtopics.\nUsing default ones.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _fetchSubtopics,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: subtopics.length,
                  itemBuilder: (context, index) {
                    final subtopic = subtopics[index];
                    final color = cardColors[index % cardColors.length];

                    return GestureDetector(
                      onTap: () {
                        // Save selected subtopic globally
                        context.read<TopicProvider>().setTopic(subtopic);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Homescreen(),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Text(
                          subtopic,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
