// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:aieducationapp/Custome_SnackBar.dart'; // Make sure this import is correct

// class AcademicDetailsPage extends StatefulWidget {
//   const AcademicDetailsPage({super.key});

//   @override
//   State<AcademicDetailsPage> createState() => _AcademicDetailsPageState();
// }

// class _AcademicDetailsPageState extends State<AcademicDetailsPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _stdController = TextEditingController();
//   final TextEditingController _sectionController = TextEditingController();
//   final TextEditingController _subjectsController = TextEditingController();

//   @override
//   void dispose() {
//     _stdController.dispose();
//     _sectionController.dispose();
//     _subjectsController.dispose();
//     super.dispose();
//   }

//   void _submitDetails() {
//     if (_formKey.currentState!.validate()) {
//       String std = _stdController.text.trim();
//       String section = _sectionController.text.trim();
//       String subjects = _subjectsController.text.trim();

//       // Show success snackbar
//       CustomeSnackbar().showCustomSnackBar(
//         context,
//         "Details saved successfully!",
//         bgColor: Colors.green,
//       );

//       // TODO: Save details to Firebase or pass to HomeScreenMain
//       print("Class: $std, Section: $section, Subjects: $subjects");

//     } else {
//       // Show error snackbar if validation fails
//       CustomeSnackbar().showCustomSnackBar(
//         context,
//         "Please fill all fields correctly",
//         bgColor: Colors.red,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Academic Details", style: GoogleFonts.poppins()),
//         backgroundColor: const Color(0xFFB589D6),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               Text(
//                 "Tell us about your academic details",
//                 style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 30),

//               // Standard/Class
//               TextFormField(
//                 controller: _stdController,
//                 decoration: InputDecoration(
//                   labelText: "Class / Standard",
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
//                   filled: true,
//                   fillColor: Colors.white,
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return "Please enter your class";
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),

//               // Section
//               TextFormField(
//                 controller: _sectionController,
//                 decoration: InputDecoration(
//                   labelText: "Section",
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
//                   filled: true,
//                   fillColor: Colors.white,
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return "Please enter your section";
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),

//               // Subjects
//               TextFormField(
//                 controller: _subjectsController,
//                 decoration: InputDecoration(
//                   labelText: "Subjects (comma separated)",
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
//                   filled: true,
//                   fillColor: Colors.white,
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return "Please enter at least one subject";
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 40),

//               // Submit Button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed:(){},
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 15),
//                     backgroundColor: const Color(0xFFB589D6),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                   ),
//                   child: Text("Submit", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
