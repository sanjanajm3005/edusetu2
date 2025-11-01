import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final String _apiKey;
  late final GenerativeModel _primaryModel;
  late final GenerativeModel _fallbackModel;

  GeminiService({required String apiKey}) : _apiKey = apiKey {
    // ✅ Use latest stable Gemini models
    _primaryModel = GenerativeModel(
      model: 'models/gemini-2.5-flash-lite',
      apiKey: _apiKey,
    );

    _fallbackModel = GenerativeModel(
      model: 'models/gemini-2.5-pro', 
      apiKey: _apiKey,
    );
  }

  /// Generates text using Gemini API, with fallback and retries.
  Future<String> askGemini(String prompt, {int retries = 3}) async {
    for (int i = 0; i < retries; i++) {
      try {
        final response = await _primaryModel.generateContent([Content.text(prompt)]);
        if (response.text?.isNotEmpty == true) return response.text!;
        return "⚠️ I couldn’t find an answer. Try rephrasing your question.";
      } catch (e) {
        final err = e.toString();

        // Handle invalid API key or network failure
        if (err.contains("Invalid API key")) {
          return "🚫 Invalid Gemini API key. Please use a valid key from https://aistudio.google.com/app/apikey.";
        }

        // Retry logic for temporary service errors
        if (err.contains("503") && i < retries - 1) {
          await Future.delayed(const Duration(seconds: 2));
          continue;
        }

        // Use fallback model if primary fails
        try {
          final fallbackResponse = await _fallbackModel.generateContent([Content.text(prompt)]);
          if (fallbackResponse.text?.isNotEmpty == true) return fallbackResponse.text!;
          return "⚠️ Fallback model also returned no response.";
        } catch (e2) {
          return "❌ Both models failed. Please try again later.";
        }
      }
    }
    return "⚠️ Model overloaded. Try again later.";
  }

  /// Helper for study notes
  static Future<String> generateNotes(String title, String description) async {
    const apiKey = 'AIzaSyB9eidTJTU0VyErijXmdQZZ1Ec367Otg10'; 
    final gemini = GeminiService(apiKey: apiKey);

    final prompt = '''
Generate clear, well-structured study notes for the topic: "$title".

Focus specifically on: $description.

Include:
- Key concepts and definitions
- Formulas (if any)
- Simple examples
- Bullet points for clarity

Keep it short, easy to understand, and formatted for students.
''';

    return await gemini.askGemini(prompt);
  }
}
