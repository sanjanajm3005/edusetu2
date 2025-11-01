import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../view/ThemePrivider.dart';

class AdminAddSubject extends StatefulWidget {
  const AdminAddSubject({super.key});

  @override
  State<AdminAddSubject> createState() => _AdminAddSubjectState();
}

class _AdminAddSubjectState extends State<AdminAddSubject> {
  final TextEditingController _subjectNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool isLoading = false;

  Future<void> addSubject() async {
    final name = _subjectNameController.text.trim();
    final desc = _descriptionController.text.trim();

    if (name.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('subjects').add({
        'name': name,
        'description': desc,
        'createdAt': Timestamp.now(),
      });

      _subjectNameController.clear();
      _descriptionController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$name added successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Subject", style: GoogleFonts.poppins()),
        backgroundColor: ThemeManager.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _subjectNameController,
              decoration: InputDecoration(
                labelText: "Subject Name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 30),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: addSubject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeManager.ButtColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      "Add Subject",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, color: Colors.black),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
