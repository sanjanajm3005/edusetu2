import 'package:ai_edu_app/view/TopicProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:open_filex/open_filex.dart';
import '../controller/Gemini_Service.dart'; // your service; must implement askGemini()
import '../utils/pdf_gernerator.dart'; // your PDF generator
import 'ThemePrivider.dart';

class NotesSection extends StatefulWidget {
  const NotesSection({super.key, required String subject});

  @override
  State<NotesSection> createState() => _NotesSectionState();
}

class _NotesSectionState extends State<NotesSection> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String _generatedText = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoGenerateNotesForTopic();
    });
  }

  Future<void> _autoGenerateNotesForTopic() async {
    final topic = context.read<TopicProvider>().selectedTopic;
    final subject = context.read<TopicProvider>().selectedSubject;
    final query = (topic.isNotEmpty) ? "$subject: $topic" : subject;
    if (query.trim().isEmpty) return;
    _controller.text = query;
    await _generateNotes(query);
  }

  Future<void> _generateNotes(String topic) async {
    if (topic.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a topic to generate notes.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prompt = '''
Generate clear, structured, and educational notes for the topic "$topic".
Include:
- Key definitions
- Main concepts
- Examples (if applicable)
- Important formulas or facts
Keep the language simple and student-friendly.
''';

      // Replace with your GeminiService implementation
      final generatedText = await GeminiService(apiKey: "AIzaSyB9eidTJTU0VyErijXmdQZZ1Ec367Otg10").askGemini(prompt);

      setState(() {
        _generatedText = generatedText ?? "";
      });

      // Create PDF using your existing utility
      final pdfFile = await PDFGenerator.generateNotePDF(topic, _generatedText);

      if (pdfFile != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notes for "$topic" generated successfully!'),
            action: SnackBarAction(
              label: 'Open PDF',
              onPressed: () => OpenFilex.open(pdfFile.path),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notes generated (no PDF).')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating notes: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = ThemeManager.topContainerColor;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [themeColor.withOpacity(0.95), themeColor.withOpacity(0.75)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          "AI Study Notes",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // Search box (pre-filled)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: themeColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onSubmitted: (v) => _generateNotes(v),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: themeColor),
                  hintText: "Enter a topic (e.g., Photosynthesis, Algebra)",
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                ),
              ),
            ),
            const SizedBox(height: 35),

            // Display or loading
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isLoading
                    ? Column(
                        key: const ValueKey('loading'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: themeColor),
                          const SizedBox(height: 20),
                          Text(
                            "Generating your notes...",
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                        ],
                      )
                    : _generatedText.isEmpty
                        ? Column(
                            key: const ValueKey('idle'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.menu_book_rounded, size: 120, color: themeColor),
                              const SizedBox(height: 15),
                              Text(
                                "Enter a topic to generate study notes!",
                                style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        : SingleChildScrollView(
                            key: const ValueKey('result'),
                            child: SelectableText(
                              _generatedText,
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: themeColor,
        elevation: 4,
        onPressed: _isLoading ? null : () => _generateNotes(_controller.text),
        label: Text(
          "Generate Notes",
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.white),
      ),
    );
  }
}
