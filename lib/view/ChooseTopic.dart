import 'package:ai_edu_app/controller/Gemini_Service.dart';
import 'package:ai_edu_app/view/ChooseSubTopic.dart';
import 'package:ai_edu_app/view/Homescreen.dart';
import 'package:ai_edu_app/view/TopicProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChooseTopic extends StatefulWidget {
  final String subject;

  const ChooseTopic({super.key, required this.subject});

  @override
  State<ChooseTopic> createState() => _ChooseTopicState();
}

class _ChooseTopicState extends State<ChooseTopic> {
  List<String> topics = [];
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _fetchTopics();
  }

  Future<void> _fetchTopics() async {
    try {
      const apiKey = 'AIzaSyB9eidTJTU0VyErijXmdQZZ1Ec367Otg10';
      final gemini = GeminiService(apiKey: apiKey);

      final prompt = '''
List all possible important subtopics or chapters usually studied under the subject "${widget.subject}".
Return only topic names, separated by commas, without numbering or extra text.
''';

      final response = await gemini.askGemini(prompt);

      final fetchedTopics = response
          .split(RegExp(r'[,\n]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      setState(() {
        topics = fetchedTopics.isNotEmpty
            ? fetchedTopics
            : ["General Overview", "Introduction"];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        topics = ["General Overview", "Introduction"];
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
          "Choose Topic",
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
                        "Failed to load topics.\nUsing default ones.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _fetchTopics,
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
                  itemCount: topics.length,
                  itemBuilder: (context, index) {
                    final topic = topics[index];
                    final cardColor = cardColors[index % cardColors.length];

                    return GestureDetector(
                     onTap: () {
  context.read<TopicProvider>().setTopic(topic);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChooseSubtopic(
        subject: widget.subject,
        topic: topic,
      ),
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
                        child: Text(
                          topic,
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
