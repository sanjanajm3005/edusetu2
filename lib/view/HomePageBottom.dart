import 'package:ai_edu_app/view/ChooseSub.dart';
import 'package:ai_edu_app/view/DoubtSolver.dart';
import 'package:ai_edu_app/view/ProgressSection.dart';
import 'package:ai_edu_app/view/ThemePrivider.dart';
import 'package:ai_edu_app/view/TopicProvider.dart';
import 'package:ai_edu_app/view/VideosSection.dart';
import 'package:ai_edu_app/view/NotesSection.dart';
import 'package:ai_edu_app/view/ProfilePage.dart';
import 'package:ai_edu_app/view/quizSection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePageBottom extends StatefulWidget {
  const HomePageBottom({super.key, required this.onPageChanged});
  final void Function(int index) onPageChanged;

  @override
  State<HomePageBottom> createState() => _HomePageBottomState();
}

class _HomePageBottomState extends State<HomePageBottom> {
  int selectedIndex = 0;

  Future<void> onItemTapped(int index) async {
    final topicProvider = context.read<TopicProvider>();
    final selectedSubject = topicProvider.selectedSubject;

    // 🧠 Prevent access without subject
    if ((index == 1 || index == 2 || index == 3) &&
        (selectedSubject.isEmpty || selectedSubject == "")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please choose a subject before continuing."),
          backgroundColor: ThemeManager.primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedSubject', selectedSubject);

    if (index == 1) {
      _openBottomSheet(VideosPage(subject: selectedSubject));
    } else if (index == 2) {
      _openBottomSheet(NotesSection(subject: selectedSubject));
    } else if (index == 3) {
      _openBottomSheet(QuizSection(subject: selectedSubject));
    } else if (index == 4) {
      _openBottomSheet(const ProfilePage());
    } else {
      setState(() => selectedIndex = index);
      widget.onPageChanged(index);
    }
  }

  void _openBottomSheet(Widget content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final height = MediaQuery.of(context).size.height;
        return Container(
          height: height * 0.8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: content,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: const HomeContentPage(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black26.withOpacity(0.1), blurRadius: 8),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          selectedItemColor: ThemeManager.primaryColor,
          unselectedItemColor: Colors.black54,
          onTap: onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.play_circle_fill), label: "Videos"),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Notes"),
            BottomNavigationBarItem(icon: Icon(Icons.quiz), label: "Quiz"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}

// ---------------- HOME CONTENT PAGE ----------------
class HomeContentPage extends StatefulWidget {
  const HomeContentPage({super.key});

  @override
  State<HomeContentPage> createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage>
    with SingleTickerProviderStateMixin {
  int selectedQuizzes = 1;
  int selectedNotes = 1;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final topicProvider = context.watch<TopicProvider>();
    final currentSubject = topicProvider.selectedSubject;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (currentSubject.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Center(
                child: Text(
                  "📘 Currently Learning: $currentSubject",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          Center(
            child: Lottie.asset(
              'assets/animations/onlineLec.json',
              width: isSmallScreen ? 240 : 280,
              height: isSmallScreen ? 180 : 200,
              fit: BoxFit.fill,
            ),
          ),
          const SizedBox(height: 8),
          _buildDoubtSolverBox(context, isSmallScreen),
          const SizedBox(height: 25),
          _buildChooseSubjectBox(context),
          const SizedBox(height: 25),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildTargetBox(context)),
              const SizedBox(width: 14),
              Expanded(child: _buildProgressBox(context)),
            ],
          ),
        ],
      ),
    );
  }

  //  Doubt Solver Box 
  Widget _buildDoubtSolverBox(BuildContext context, bool isSmallScreen) {
    return _buildBox(
      color: ThemeManager.otherColor,
      icon: Icons.chat_bubble_outline,
      title: "Doubt Solver",
      buttonText: "Open",
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DoubtSolverPage()),
      ),
    );
  }

  // Choose Subject Box 
  Widget _buildChooseSubjectBox(BuildContext context) {
    return FadeTransition(
      opacity: _glowController.drive(Tween(begin: 0.8, end: 1.0)),
      child: _buildBox(
        color: ThemeManager.otherColor2.withOpacity(0.9),
        icon: Icons.book_outlined,
        title: "Choose Subject & Continue Learning",
        subtitle:
            "Pick a subject to explore topic-wise videos, notes, and quizzes.",
        buttonText: "Choose Subject",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChooseSub()),
          );
        },
      ),
    );
  }

  // Target & Progress Common Box Builder 
  Widget _buildBox({
    required Color color,
    required IconData icon,
    required String title,
    String? subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12.withOpacity(0.15), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: const Color(0xFF0D0A2E), size: 26),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 15)),
            ),
          ]),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87)),
          ],
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeManager.ButtColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              child: Text(buttonText,
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetBox(BuildContext context) => _buildBox(
        color: ThemeManager.otherColor.withOpacity(0.8),
        icon: Icons.track_changes,
        title: "Set Target",
        subtitle: "Choose your daily goals for quizzes and notes.",
        buttonText: "Set",
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Target set successfully!"),
              backgroundColor: ThemeManager.otherColor,
            ),
          );
        },
      );

  Widget _buildProgressBox(BuildContext context) => _buildBox(
        color: ThemeManager.otherColor2.withOpacity(0.8),
        icon: Icons.insights,
        title: "View Progress",
        subtitle: "Track your quiz and note completion progress.",
        buttonText: "View",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProgressSection()),
          );
        },
      );
}
