import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:step_out/screens/home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

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
  final String imgbbApiKey = '19407688fd34967e68bd5c69ef5378a4';

  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _image = File(pickedFile.path));
      }
    } catch (e) {
      setState(() => error = 'Failed to pick image: $e');
    }
  }
  Future<String?> _uploadToImgBB() async {
    if (_image == null) return null;

    try {
      final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$imgbbApiKey');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath(
          'image',
          _image!.path,
          contentType: MediaType('image', 'jpeg'),
        ));

      final response = await request.send();
      final data = await response.stream.bytesToString();
      final jsonData = json.decode(data);

      if (jsonData['success'] == true) {
        return jsonData['data']['url'];
      } else {
        throw Exception('ImgBB upload failed: ${jsonData['error']['message']}');
      }
    } catch (e) {
      print('ImgBB upload error: $e');
      return null;
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
          email: widget.email,
          password: widget.password);

      final userId = userCredential.user!.uid;
      String? profilePictureUrl;
      if(_image!=null)
        {
          profilePictureUrl = await _uploadToImgBB();

        }

      final userData = {
        'email': widget.email,
        'firstName': widget.firstName,
        'lastName': widget.lastName,
        'username': widget.username,
        'birthdate': widget.birthdate,
        'country': widget.country,
        'gender': widget.gender,
        'job': widget.job,
        'interests': widget.interests,
        'profilePicture': profilePictureUrl, // Will be null if no image
        'createdAt': FieldValue.serverTimestamp(),
        'uid': userId,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(userData);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => home_screen()),
              (route) => false,
        );

      }
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message ?? 'Authentication failed');
    } catch (e) {
      setState(() => error = 'Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
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
                backgroundColor: _image == null ? const Color(0xFFE9FBF4) : null,
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null
                    ? const Icon(Icons.person, color: Color(0xFF10B981), size: 110)
                    : null,
              ),
            ),
            const SizedBox(height: 150),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red, fontFamily: 'Dosis')),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
              onPressed: completeSignUp,
              icon: const Icon(Icons.check, color: Color(0xFFE9FBF4)),
              label: const Text("Finish Sign Up!", style: TextStyle(fontFamily: 'Dosis', color: Colors.white, fontSize: 18)),
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