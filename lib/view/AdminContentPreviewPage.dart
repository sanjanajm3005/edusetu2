import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_edu_app/view/ThemePrivider.dart';

class ContentPreviewPage extends StatefulWidget {
  final String subjectId;
  final String topicId;
  final String topicName;

  const ContentPreviewPage({
    super.key,
    required this.subjectId,
    required this.topicId,
    required this.topicName,
  });

  @override
  State<ContentPreviewPage> createState() => _ContentPreviewPageState();
}

class _ContentPreviewPageState extends State<ContentPreviewPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Stream<QuerySnapshot> _getContentStream(String type) {
    return _firestore
        .collection('subjects')
        .doc(widget.subjectId)
        .collection('topics')
        .doc(widget.topicId)
        .collection('contents')
        .where('type', isEqualTo: type)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeManager.secondaryColor,
      appBar: AppBar(
        backgroundColor: ThemeManager.primaryColor,
        title: Text(
          widget.topicName,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black54,
          indicatorColor: ThemeManager.ButtColor,
          tabs: const [
            Tab(icon: Icon(Icons.play_circle_fill), text: "Videos"),
            Tab(icon: Icon(Icons.menu_book), text: "Notes"),
            Tab(icon: Icon(Icons.quiz), text: "Quizzes"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildContentList("video"),
          _buildContentList("note"),
          _buildContentList("quiz"),
        ],
      ),
    );
  }

  Widget _buildContentList(String type) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getContentStream(type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "No $type content available",
              style: GoogleFonts.poppins(color: Colors.black54),
            ),
          );
        }

        final contents = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: contents.length,
          itemBuilder: (context, index) {
            final data = contents[index].data() as Map<String, dynamic>;
            final title = data['title'] ?? 'Untitled';
            final link = data['link'] ?? '';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: Icon(
                  type == "video"
                      ? Icons.play_circle_fill
                      : type == "note"
                          ? Icons.menu_book
                          : Icons.quiz,
                  color: ThemeManager.primaryColor,
                  size: 35,
                ),
                title: Text(
                  title,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  link,
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_new),
                  onPressed: () {
                    _openLink(link, type);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openLink(String link, String type) {
    if (link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid or missing link")),
      );
      return;
    }

    // You can later open YouTube, PDF, or quiz page here.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Opening $type: $link")),
    );
  }
}
