import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../view/ThemePrivider.dart';

class AdminManageTopics extends StatefulWidget {
  const AdminManageTopics({super.key});

  @override
  State<AdminManageTopics> createState() => _AdminManageTopicsState();
}

class _AdminManageTopicsState extends State<AdminManageTopics> {
  String? selectedSubject;
  final TextEditingController _topicController = TextEditingController();
  bool isLoading = false;

  Future<void> addTopic() async {
    if (selectedSubject == null || _topicController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a subject and enter topic name")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .where('name', isEqualTo: selectedSubject)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final subjectId = querySnapshot.docs.first.id;

        await FirebaseFirestore.instance
            .collection('subjects')
            .doc(subjectId)
            .collection('topics')
            .add({
          'name': _topicController.text.trim(),
          'createdAt': Timestamp.now(),
        });

        _topicController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Topic added to $selectedSubject!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding topic: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Topics", style: GoogleFonts.poppins()),
        backgroundColor: ThemeManager.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('subjects').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();

                final subjects = snapshot.data!.docs.map((e) => e['name'].toString()).toList();

                return DropdownButtonFormField<String>(
                  value: selectedSubject,
                  decoration: InputDecoration(
                    labelText: "Select Subject",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) => setState(() => selectedSubject = val),
                );
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _topicController,
              decoration: InputDecoration(
                labelText: "Topic Name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: addTopic,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeManager.ButtColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      "Add Topic",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, color: Colors.black),
                    ),
                  ),
            const SizedBox(height: 30),
            if (selectedSubject != null)
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('subjects')
                      .where('name', isEqualTo: selectedSubject)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No subjects found."));
                    }

                    final subjectDoc = snapshot.data!.docs.first;

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('subjects')
                          .doc(subjectDoc.id)
                          .collection('topics')
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, topicSnapshot) {
                        if (!topicSnapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final topics = topicSnapshot.data!.docs;

                        if (topics.isEmpty) {
                          return const Center(child: Text("No topics added yet."));
                        }

                        return ListView.builder(
                          itemCount: topics.length,
                          itemBuilder: (context, index) {
                            final topic = topics[index]['name'];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                title: Text(topic, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('subjects')
                                        .doc(subjectDoc.id)
                                        .collection('topics')
                                        .doc(topics[index].id)
                                        .delete();
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
