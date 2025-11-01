import 'package:flutter/material.dart';
import 'package:ai_edu_app/view/LoginScreen.dart';
import 'package:ai_edu_app/view/SignUp.dart';

class AuthScreen extends StatefulWidget {
  final int startIndex; // 0 = login, 1 = signup
  const AuthScreen({super.key, this.startIndex = 0});

  @override
  State<AuthScreen> createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  late int currentIndex;

  final List<Widget> pages = [
    const LoginScreen(),
    const SignUpScreen(),
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.startIndex; // start with correct tab
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: "Login",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: "Sign Up",
          ),
        ],
      ),
    );
  }
}
