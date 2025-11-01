import 'dart:convert';
import 'package:ai_edu_app/view/TopicProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../controller/Gemini_Service.dart'; // or use google_generative_ai per your setup
import 'ThemePrivider.dart';

class QuizSection extends StatefulWidget {
   final String subject;
  const QuizSection({super.key, required this.subject});

  @override
  State<QuizSection> createState() => _QuizSectionState();
}

class _QuizSectionState extends State<QuizSection> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  bool _quizStarted = false;
  bool _showResult = false;
  int _currentQuestionIndex = 0;
  int _score = 0;
  List<Map<String, dynamic>> _questions = [];
  String _selectedOption = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoGenerateQuizForTopic();
    });
  }

  Future<void> _autoGenerateQuizForTopic() async {
    final topic = context.read<TopicProvider>().selectedTopic;
    final subject = context.read<TopicProvider>().selectedSubject;
    final query = (topic.isNotEmpty) ? "$subject: $topic" : subject;
    if (query.trim().isEmpty) return;
    _controller.text = query;
    await _generateQuiz(query);
  }

  Future<void> _generateQuiz(String topic) async {
    setState(() {
      _loading = true;
      _quizStarted = false;
      _questions.clear();
      _showResult = false;
      _currentQuestionIndex = 0;
      _score = 0;
      _selectedOption = "";
    });

    try {
      final prompt = """
Generate 5 multiple-choice quiz questions about "$topic".
Each question must be in JSON format like this:
[
  {
    "question": "Question text",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "answer": "Correct answer text"
  }
]
Return only valid JSON, no explanation.
""";

      // Use your GeminiService (replace with your implementation)
      final responseText = await GeminiService(apiKey: "AIzaSyB9eidTJTU0VyErijXmdQZZ1Ec367Otg10").askGemini(prompt);

      final cleanJson = responseText.trim().replaceAll("```json", "").replaceAll("```", "");

      final List<dynamic> parsed = jsonDecode(cleanJson);
      setState(() {
        _questions = parsed.cast<Map<String, dynamic>>();
        _quizStarted = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error generating quiz: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _checkAnswer(String selected) {
    setState(() => _selectedOption = selected);
    final correct = _questions[_currentQuestionIndex]['answer'];
    if (selected == correct) _score++;

    Future.delayed(const Duration(seconds: 1), () {
      if (_currentQuestionIndex < _questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedOption = "";
        });
      } else {
        setState(() => _showResult = true);
      }
    });
  }

  void _restartQuiz() {
    setState(() {
      _showResult = false;
      _quizStarted = false;
      _questions.clear();
      _controller.clear();
      _score = 0;
      _selectedOption = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = ThemeManager.topContainerColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: Container(
          decoration: BoxDecoration(
            color: ThemeManager.topContainerColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.only(top: 10),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Center(
                    child: Text(
                      "Smart Quiz",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Enter topic (e.g., Photosynthesis, Algebra)",
                        hintStyle: GoogleFonts.poppins(fontSize: 14),
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_controller.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please enter a topic")),
                        );
                      } else {
                        _generateQuiz(_controller.text.trim());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeManager.topContainerColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(14),
                    ),
                    child: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _showResult
                      ? _buildResultScreen()
                      : !_quizStarted
                          ? _buildIntroUI()
                          : _buildQuizContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_rounded, size: 120, color: ThemeManager.topContainerColor),
          const SizedBox(height: 20),
          Text(
            "Enter a topic above and tap the arrow to start your quiz!",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent() {
    final question = _questions[_currentQuestionIndex];
    final options = question['options'] as List;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _questions.length,
            color: ThemeManager.topContainerColor,
            backgroundColor: Colors.grey[300],
            minHeight: 8,
          ),
          const SizedBox(height: 20),
          Text(
            "Question ${_currentQuestionIndex + 1} of ${_questions.length}",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            question['question'],
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          ...options.map((option) {
            final correct = question['answer'];
            Color bgColor = Colors.grey[200]!;

            if (_selectedOption.isNotEmpty) {
              if (option == correct) {
                bgColor = Colors.greenAccent.shade400;
              } else if (option == _selectedOption && option != correct) {
                bgColor = Colors.redAccent.shade200;
              }
            }

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(vertical: 6),
              width: double.infinity,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: ElevatedButton(
                onPressed: _selectedOption.isEmpty ? () => _checkAnswer(option) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(option, style: GoogleFonts.poppins(fontSize: 15)),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    final percent = (_score / _questions.length) * 100;
    final success = percent >= 50;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            success ? "assets/animations/success.json" : "assets/animations/tryAgain.json",
            width: 200,
            height: 200,
            repeat: false,
          ),
          const SizedBox(height: 20),
          Text("Your Score", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
          Text(
            "$_score / ${_questions.length}",
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: success ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _restartQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeManager.topContainerColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
            ),
            child: Text("Try Another Topic", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
