import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_edu_app/view/ThemePrivider.dart';

class AdminTopicManager extends StatefulWidget {
  const AdminTopicManager({super.key});

  @override
  State<AdminTopicManager> createState() => _AdminTopicManagerState();
}

class _AdminTopicManagerState extends State<AdminTopicManager> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedSubjectId;
  String? selectedSubjectName;
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool isEditing = false;
  String? editingTopicId;

  // Save or update topic
  Future<void> _saveTopic() async {
    final topicName = _topicController.text.trim();
    final topicDesc = _descController.text.trim();

    if (selectedSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a subject first")),
      );
      return;
    }

    if (topicName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter topic name")),
      );
      return;
    }

    try {
      final topicCollection = _firestore
          .collection('subjects')
          .doc(selectedSubjectId)
          .collection('topics');

      if (isEditing && editingTopicId != null) {
        await topicCollection.doc(editingTopicId).update({
          'name': topicName,
          'description': topicDesc,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Topic updated successfully")),
        );
      } else {
        await topicCollection.add({
          'name': topicName,
          'description': topicDesc,
          'createdAt': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Topic added successfully")),
        );
      }

      _topicController.clear();
      _descController.clear();
      setState(() {
        isEditing = false;
        editingTopicId = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // Edit topic
  void _editTopic(String id, String name, String desc) {
    setState(() {
      isEditing = true;
      editingTopicId = id;
      _topicController.text = name;
      _descController.text = desc;
    });
  }

  // Delete topic
  Future<void> _deleteTopic(String id) async {
    if (selectedSubjectId == null) return;
    await _firestore
        .collection('subjects')
        .doc(selectedSubjectId)
        .collection('topics')
        .doc(id)
        .delete();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Topic deleted")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeManager.secondaryColor,
      appBar: AppBar(
        backgroundColor: ThemeManager.primaryColor,
        title: Text(
          "Manage Topics",
          style: GoogleFonts.poppins(
              color: Colors.black, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // ---------- Subject Dropdown ----------
          Padding(
            padding: const EdgeInsets.all(16),
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('subjects').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final subjects = snapshot.data!.docs;
                return DropdownButtonFormField<String>(
                  value: selectedSubjectId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: "Select Subject",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: subjects.map((doc) {
                    final name = doc['name'] ?? 'Unnamed';
                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSubjectId = value;
                      selectedSubjectName = subjects
                          .firstWhere((d) => d.id == value)['name']
                          .toString();
                    });
                  },
                );
              },
            ),
          ),

          // ---------- Add Topic Form ----------
          if (selectedSubjectId != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12.withOpacity(0.15), blurRadius: 8)
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _topicController,
                      decoration: const InputDecoration(
                        labelText: "Topic Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        labelText: "Description (optional)",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: _saveTopic,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeManager.ButtColor,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: Icon(isEditing ? Icons.save : Icons.add,
                          color: Colors.black),
                      label: Text(
                        isEditing ? "Update Topic" : "Add Topic",
                        style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ---------- Topics List ----------
          if (selectedSubjectId != null)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('subjects')
                    .doc(selectedSubjectId)
                    .collection('topics')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final topics = snapshot.data!.docs;
                  if (topics.isEmpty) {
                    return Center(
                      child: Text(
                        "No topics found for $selectedSubjectName",
                        style: GoogleFonts.poppins(
                            fontSize: 16, color: Colors.black54),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: topics.length,
                    itemBuilder: (context, index) {
                      final data = topics[index].data() as Map<String, dynamic>;
                      final name = data['name'] ?? '';
                      final desc = data['description'] ?? '';
                      final id = topics[index].id;

                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(name,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87)),
                          subtitle: desc.isNotEmpty
                              ? Text(desc,
                                  style: GoogleFonts.poppins(fontSize: 13))
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editTopic(id, name, desc),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteTopic(id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
