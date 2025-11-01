import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_edu_app/view/ThemePrivider.dart';

class AdminSubjectManager extends StatefulWidget {
  const AdminSubjectManager({super.key});

  @override
  State<AdminSubjectManager> createState() => _AdminSubjectManagerState();
}

class _AdminSubjectManagerState extends State<AdminSubjectManager> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  bool isEditing = false;
  String? editingId;

  // Add or update subject
  Future<void> _saveSubject() async {
    final name = _nameController.text.trim();
    final desc = _descController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a subject name")),
      );
      return;
    }

    try {
      if (isEditing && editingId != null) {
        // Update existing subject
        await _firestore.collection('subjects').doc(editingId).update({
          'name': name,
          'description': desc,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Subject updated successfully")),
        );
      } else {
        // Add new subject
        await _firestore.collection('subjects').add({
          'name': name,
          'description': desc,
          'createdAt': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Subject added successfully")),
        );
      }

      _nameController.clear();
      _descController.clear();
      setState(() {
        isEditing = false;
        editingId = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // Edit subject
  void _editSubject(String id, String name, String desc) {
    setState(() {
      isEditing = true;
      editingId = id;
      _nameController.text = name;
      _descController.text = desc;
    });
  }

  // Delete subject
  Future<void> _deleteSubject(String id) async {
    await _firestore.collection('subjects').doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Subject deleted")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeManager.secondaryColor,
      appBar: AppBar(
        backgroundColor: ThemeManager.primaryColor,
        title: Text(
          "Manage Subjects",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // ---------- Add / Edit Form ----------
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: Colors.black12.withOpacity(0.15), blurRadius: 8),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Subject Name",
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
                    onPressed: _saveSubject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeManager.ButtColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(isEditing ? Icons.save : Icons.add, color: Colors.black),
                    label: Text(
                      isEditing ? "Update Subject" : "Add Subject",
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---------- Subjects List ----------
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('subjects').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No subjects available yet.",
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
                    ),
                  );
                }

                final subjects = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final data = subjects[index].data() as Map<String, dynamic>;
                    final name = data['name'] ?? 'Unnamed';
                    final desc = data['description'] ?? '';
                    final id = subjects[index].id;

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: desc.isNotEmpty
                            ? Text(desc, style: GoogleFonts.poppins(fontSize: 13))
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blueAccent),
                              onPressed: () => _editSubject(id, name, desc),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _deleteSubject(id),
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
