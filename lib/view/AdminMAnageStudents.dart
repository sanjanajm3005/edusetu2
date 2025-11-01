import 'package:ai_edu_app/view/ThemePrivider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class AdminManageStudentsPage extends StatefulWidget {
  const AdminManageStudentsPage({super.key});

  @override
  State<AdminManageStudentsPage> createState() => _AdminManageStudentsPageState();
}

class _AdminManageStudentsPageState extends State<AdminManageStudentsPage> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeManager.secondaryColor,
      appBar: AppBar(
        backgroundColor: ThemeManager.primaryColor,
        title: Text(
          "Manage Students",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search by name or email...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 👨‍🎓 Students List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No students found"));
                }

                final students = snapshot.data!.docs.where((doc) {
                  final name = (doc['name'] ?? '').toString().toLowerCase();
                  final email = (doc['email'] ?? '').toString().toLowerCase();
                  return name.contains(searchQuery) || email.contains(searchQuery);
                }).toList();

                if (students.isEmpty) {
                  return const Center(child: Text("No matching students found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final isBlocked = student['isBlocked'] ?? false;

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: ThemeManager.otherColor,
                          child: Text(
                            student['name'] != null && student['name'].isNotEmpty
                                ? student['name'][0].toUpperCase()
                                : "?",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          student['name'] ?? 'Unnamed User',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          "${student['email'] ?? 'No Email'}\nGrade: ${student['grade'] ?? 'N/A'}",
                          style: GoogleFonts.poppins(fontSize: 13, color: Colors.black54),
                        ),
                        isThreeLine: true,
                        trailing: Switch(
                          value: isBlocked,
                          onChanged: (value) async {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(student.id)
                                .update({'isBlocked': value});
                          },
                          activeColor: Colors.red,
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
