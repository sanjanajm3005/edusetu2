import 'package:ai_edu_app/view/AdminHomePage.dart';
import 'package:ai_edu_app/view/ChooseSub.dart';
import 'package:ai_edu_app/view/Homescreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ai_edu_app/view/Custome_SnackBar.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "SmartLearn.",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFb5ca8d),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 120.0),
                child: Lottie.asset("assets/animations/Login (1).json",
                    width: 200, height: 200),
              ),
              const SizedBox(height: 30),
              Text(
                "Welcome Back!",
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 25),

              // 📧 Email Field
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Email",
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🔒 Password Field
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  filled: true,
                  fillColor: Colors.white,
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 35),

              // 🔘 Login Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3a365b), Color(0xFF482e77)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () async {
                    if (emailController.text.isNotEmpty &&
                        passwordController.text.isNotEmpty) {
                      // ADMIN LOGIN 
                      if (emailController.text == 'admin@gmail.com' &&
                          passwordController.text == 'admin123') {
                        CustomeSnackbar().showCustomSnackBar(
                          context,
                          "Admin Login Successful!",
                          bgColor: Colors.green,
                        );
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => const AdminHomePage()),
                        );
                        return;
                      }

                      // 👤 NORMAL USER LOGIN
                      try {
                        await firebaseAuth.signInWithEmailAndPassword(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                        );
                        CustomeSnackbar().showCustomSnackBar(
                          context,
                          "Login Successful!",
                          bgColor: Colors.green,
                        );
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => Homescreen(),
                          ),
                        );
                      } on FirebaseAuthException catch (e) {
                        CustomeSnackbar().showCustomSnackBar(
                          context,
                          e.message ?? "Invalid credentials",
                          bgColor: Colors.red,
                        );
                      }
                    } else {
                      CustomeSnackbar().showCustomSnackBar(
                        context,
                        "Please enter valid credentials",
                        bgColor: Colors.red,
                      );
                    }
                  },
                  child: Text(
                    "Log In",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
