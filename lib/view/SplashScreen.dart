
import 'package:flutter/material.dart';

import 'LoginScreen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void navigateToScreen(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) {
            return LoginScreen();
          },
        ),
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   navigateToScreen(context);
   return Scaffold(
    body:Center(child: Image.network("https://images.unsplash.com/photo-1759269106058-a52e5ac35e01?q=80&w=387&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"),)
   );
  }
}
