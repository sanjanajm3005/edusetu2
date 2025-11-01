import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../view/ThemePrivider.dart';

class AdminAnalytics extends StatefulWidget {
  const AdminAnalytics({super.key});

  @override
  State<AdminAnalytics> createState() => _AdminAnalyticsState();
}

class _AdminAnalyticsState extends State<AdminAnalytics> {
  int totalUsers = 0;
  int totalSubjects = 0;
  int totalTopics = 0;
  int totalContents = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    try {
      final usersSnap = await FirebaseFirestore.instance.collection('users').get();
      final subjectsSnap = await FirebaseFirestore.instance.collection('subjects').get();

      int topicsCount = 0;
      int contentsCount = 0;

      for (var subjectDoc in subjectsSnap.docs) {
        final topicsSnap = await FirebaseFirestore.instance
            .collection('subjects')
            .doc(subjectDoc.id)
            .collection('topics')
            .get();

        topicsCount += topicsSnap.size;

        for (var topicDoc in topicsSnap.docs) {
          final contentsSnap = await FirebaseFirestore.instance
              .collection('subjects')
              .doc(subjectDoc.id)
              .collection('topics')
              .doc(topicDoc.id)
              .collection('contents')
              .get();

          contentsCount += contentsSnap.size;
        }
      }

      setState(() {
        totalUsers = usersSnap.size;
        totalSubjects = subjectsSnap.size;
        totalTopics = topicsCount;
        totalContents = contentsCount;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading analytics: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeManager.secondaryColor,
      appBar: AppBar(
        title: Text("Analytics Dashboard", style: GoogleFonts.poppins()),
        backgroundColor: ThemeManager.primaryColor,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchAnalytics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Lottie.asset('assets/animations/analytics.json',
                        height: 180, repeat: true),
                    const SizedBox(height: 20),

                    _buildStatCard(
                      title: "Registered Users",
                      value: totalUsers.toString(),
                      icon: Icons.people,
                      color: Colors.blueAccent,
                    ),
                    _buildStatCard(
                      title: "Subjects Added",
                      value: totalSubjects.toString(),
                      icon: Icons.book,
                      color: Colors.deepPurpleAccent,
                    ),
                    _buildStatCard(
                      title: "Topics Created",
                      value: totalTopics.toString(),
                      icon: Icons.topic,
                      color: Colors.orangeAccent,
                    ),
                    _buildStatCard(
                      title: "Total Contents",
                      value: totalContents.toString(),
                      icon: Icons.video_library,
                      color: Colors.teal,
                    ),

                    const SizedBox(height: 25),
                    Text(
                      "Swipe down to refresh data ↻",
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black12.withOpacity(0.1), blurRadius: 10)
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 15)),
              Text(value,
                  style: GoogleFonts.poppins(
                      fontSize: 22,
                      color: color,
                      fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}
