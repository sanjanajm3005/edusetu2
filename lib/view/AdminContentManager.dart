import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_edu_app/view/ThemePrivider.dart';

class AdminContentManager extends StatefulWidget {
  const AdminContentManager({super.key});

  @override
  State<AdminContentManager> createState() => _AdminContentManagerState();
}

class _AdminContentManagerState extends State<AdminContentManager> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? selectedSubjectId;
  String? selectedTopicId;
  String? selectedType;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  bool isEditing = false;
  String? editingContentId;

  // Save or update content
  Future<void> _saveContent() async {
    if (selectedSubjectId == null || selectedTopicId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select subject and topic first")),
      );
      return;
    }

    final title = _titleController.text.trim();
    final link = _linkController.text.trim();
    final type = selectedType ?? "";

    if (title.isEmpty || link.isEmpty || type.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields properly")),
      );
      return;
    }

    final contentCollection = _firestore
        .collection('subjects')
        .doc(selectedSubjectId)
        .collection('topics')
        .doc(selectedTopicId)
        .collection('contents');

    try {
      if (isEditing && editingContentId != null) {
        await contentCollection.doc(editingContentId).update({
          'title': title,
          'link': link,
          'type': type,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Content updated successfully")),
        );
      } else {
        await contentCollection.add({
          'title': title,
          'link': link,
          'type': type,
          'createdAt': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Content added successfully")),
        );
      }

      _titleController.clear();
      _linkController.clear();
      setState(() {
        isEditing = false;
        editingContentId = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // Edit content
  void _editContent(String id, String title, String link, String type) {
    setState(() {
      isEditing = true;
      editingContentId = id;
      _titleController.text = title;
      _linkController.text = link;
      selectedType = type;
    });
  }

  // Delete content
  Future<void> _deleteContent(String id) async {
    if (selectedSubjectId == null || selectedTopicId == null) return;
    await _firestore
        .collection('subjects')
        .doc(selectedSubjectId)
        .collection('topics')
        .doc(selectedTopicId)
        .collection('contents')
        .doc(id)
        .delete();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Content deleted")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeManager.secondaryColor,
      appBar: AppBar(
        backgroundColor: ThemeManager.primaryColor,
        title: Text(
          "Manage Content",
          style: GoogleFonts.poppins(
              color: Colors.black, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ---------- Subject Dropdown ----------
            Padding(
              padding: const EdgeInsets.all(16),
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('subjects').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
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
                        selectedTopicId = null;
                      });
                    },
                  );
                },
              ),
            ),

            // ---------- Topic Dropdown ----------
            if (selectedSubjectId != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('subjects')
                      .doc(selectedSubjectId)
                      .collection('topics')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    final topics = snapshot.data!.docs;
                    return DropdownButtonFormField<String>(
                      value: selectedTopicId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: "Select Topic",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: topics.map((doc) {
                        final name = doc['name'] ?? 'Unnamed';
                        return DropdownMenuItem<String>(
                          value: doc.id,
                          child: Text(name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedTopicId = value);
                      },
                    );
                  },
                ),
              ),

            // ---------- Add Content Form ----------
            if (selectedTopicId != null)
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
                      DropdownButtonFormField<String>(
                        value: selectedType,
                        decoration: const InputDecoration(
                          labelText: "Select Content Type",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: "video", child: Text("Video")),
                          DropdownMenuItem(value: "note", child: Text("Note")),
                          DropdownMenuItem(value: "quiz", child: Text("Quiz")),
                        ],
                        onChanged: (value) => setState(() => selectedType = value),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: "Title",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _linkController,
                        decoration: const InputDecoration(
                          labelText: "Link (YouTube, PDF, etc.)",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton.icon(
                        onPressed: _saveContent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeManager.ButtColor,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: Icon(isEditing ? Icons.save : Icons.add,
                            color: Colors.black),
                        label: Text(
                          isEditing ? "Update Content" : "Add Content",
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

            // ---------- List of Contents ----------
            if (selectedTopicId != null)
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('subjects')
                    .doc(selectedSubjectId)
                    .collection('topics')
                    .doc(selectedTopicId)
                    .collection('contents')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final contents = snapshot.data!.docs;
                  if (contents.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "No content found for this topic",
                        style: GoogleFonts.poppins(color: Colors.black54),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: contents.length,
                    itemBuilder: (context, index) {
                      final data = contents[index].data() as Map<String, dynamic>;
                      final id = contents[index].id;
                      final title = data['title'] ?? '';
                      final link = data['link'] ?? '';
                      final type = data['type'] ?? '';

                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(title,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87)),
                          subtitle: Text("Type: $type\n$link",
                              style: GoogleFonts.poppins(fontSize: 13)),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editContent(id, title, link, type),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteContent(id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
