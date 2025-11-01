
import 'package:ai_edu_app/view/TopicProvider.dart';
import 'package:ai_edu_app/view/WelcomeScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Existing provider for search functionality
import 'controller/SearchProvider.dart';

//  New provider to manage selected subject & topic

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDMZBmnghraoyTmqpWpifjMMavLwfNb-6k",
      appId: "1:259554552827:android:46a86a1ed9fab4bcc4b95e",
      messagingSenderId: "259554552827",
      projectId: "aieducationnapp",
    ),
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => TopicProvider()), // ✅ Added new global provider
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: WelcomeScreen(),
      ),
    );
  }
}
