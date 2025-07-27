import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:step_out/screens/home_screen.dart';

class profile_picture_page extends StatefulWidget {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String username;
  final String birthdate;
  final String? country;
  final String? gender;
  final String job;
  final List<String> interests;

  const profile_picture_page({
    super.key,
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.birthdate,
    required this.country,
    required this.gender,
    required this.job,
    required this.interests,
  });

  @override
  State<profile_picture_page> createState() => _profile_picture_pageState();
}

class _profile_picture_pageState extends State<profile_picture_page> {
  File? _image;
  bool isLoading = false;
  String? error;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<void> completeSignUp() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: widget.email, password: widget.password);

      final uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': widget.email,
        'firstName': widget.firstName,
        'lastName': widget.lastName,
        'username': widget.username,
        'birthdate': widget.birthdate,
        'country': widget.country,
        'gender': widget.gender,
        'job': widget.job,
        'interests': widget.interests,
        'profilePicture': _image?.path ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) =>  home_screen()),
      );

    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message);
    } catch (e) {
      setState(() => error = 'Unexpected error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const dosisFont = TextStyle(fontFamily: 'Dosis');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Picture', style: TextStyle(fontFamily: 'Dosis')),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Add a profile picture (optional)",
                style: dosisFont.copyWith(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.black)),
            const SizedBox(height: 120),
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 140,
                backgroundColor: _image == null ? Color(0xFFE9FBF4) : null,
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null
                    ? const Icon(Icons.person, color:Color(0xFF10B981),size: 110)
                    : null,
              ),
            ),
            const SizedBox(height: 150),
            if (error != null)
              Text(error!, style: TextStyle(color: Colors.red, fontFamily: 'Dosis')),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
              onPressed: completeSignUp,
              icon: const Icon(Icons.check,color: Color(0xFFE9FBF4),),
              label: const Text("Finish Sign Up", style: TextStyle(fontFamily: 'Dosis',color: Colors.white,fontSize: 18)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF10B981),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
