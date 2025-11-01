import 'package:ai_edu_app/controller/Gemini_Service.dart';
import 'package:ai_edu_app/model/ChatMessage_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'ThemePrivider.dart';

class DoubtSolverPage extends StatefulWidget {
  const DoubtSolverPage({super.key});

  @override
  State<DoubtSolverPage> createState() => _DoubtSolverPageState();
}

class _DoubtSolverPageState extends State<DoubtSolverPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  late GeminiService _geminiService;
  final FlutterTts _flutterTts = FlutterTts();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isLoading = false;
  late AnimationController _micAnimationController;

  @override
  void initState() {
    super.initState();
    _geminiService =
        GeminiService(apiKey: 'AIzaSyB9eidTJTU0VyErijXmdQZZ1Ec367Otg10');
    _speech = stt.SpeechToText();

    // Animation for glowing mic
    _micAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.7,
      upperBound: 1.2,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _micAnimationController.dispose();
    super.dispose();
  }

  // Send user message and get response
  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _controller.clear();
      _isLoading = true;
    });

    final response = await _geminiService.askGemini(text);

    setState(() {
      _messages.add(ChatMessage(text: response, isUser: false));
      _isLoading = false;
    });
  }

  // Speak text using TTS
  Future<void> _speak(String text) async {
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  // Listen to user voice input
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => setState(() {}),
        onError: (val) => debugPrint('Speech Error: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _micAnimationController.repeat(reverse: true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _controller.text = val.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _micAnimationController.stop();
      _micAnimationController.value = 1.0;
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeManager.topContainerColor,
      appBar: AppBar(
        backgroundColor: ThemeManager.primaryColor,
        title: Text(
          "Doubt Solver",
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment:
                      msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: msg.isUser
                          ? ThemeManager.ButtColor
                          : ThemeManager.otherColor2,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Text(
                            msg.text,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (!msg.isUser)
                          IconButton(
                            icon: const Icon(Icons.volume_up,
                                color: Colors.white, size: 22),
                            onPressed: () => _speak(msg.text),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: Colors.white),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Ask your study question...",
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: ThemeManager.otherColor,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // MIC BUTTON with glow
                Transform.scale(
                  scale: _isListening ? _micAnimationController.value : 1.0,
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: _isListening
                        ? Colors.redAccent
                        : ThemeManager.ButtColor,
                    child: IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening ? Colors.white : Colors.black,
                      ),
                      onPressed: _listen,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 25,
                  backgroundColor: ThemeManager.ButtColor,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.black),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
