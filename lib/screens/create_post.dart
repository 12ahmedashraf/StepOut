import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
class create_post extends StatefulWidget {

  const create_post({
    Key? key,
}) : super(key: key);
  @override
  State<create_post> createState() => _create_postState();
}
class _create_postState extends State<create_post>{
    final TextEditingController _text_controller = TextEditingController();
    File? _selectedImage;
    bool _isLoading = false;

    int? challengePoints;
    String? challengeStep;

    @override
    void initState(){
      super.initState();
      _fetchDailyChallenge();
    }
    Future<void> _fetchDailyChallenge() async {
      final today = DateTime.now();
      final formattedDate="${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
      final doc = await FirebaseFirestore.instance
            .collection('daily_challenges')
            .doc(formattedDate)
            .get();
      if(doc.exists){
        final data = doc.data();
        if (mounted) {
          setState(() {
            challengePoints = data?['points'] ?? 0;
            challengeStep = data?['step'] ?? '';
          });
        }
      }
      else
        {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No challenge found for today.")),
            );
            Navigator.pop(context);
          }
        }
    }
    Future<void> _pickImage() async {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    }
    Future<String?> _uploadImageToImgBB(File imageFile) async {
      final apiKey = '19407688fd34967e68bd5c69ef5378a4';
      final url = Uri.parse("https://api.imgbb.com/1/upload?key=$apiKey");
      final base64Image = base64Encode(imageFile.readAsBytesSync());

      final response = await http.post(url, body: {
        "image": base64Image,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['url'];
      } else {
        print("Upload failed: ${response.body}");
        return null;
      }
    }
    Future<void> _create_post() async {
      if (_text_controller.text.trim().isEmpty && _selectedImage == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please add text or image")),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        final uid = user.uid;
        final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
        final postsRef = userRef.collection('posts');
        final stepsRef = userRef.collection('steps');

        String? imageUrl;
        if (_selectedImage != null) {
          imageUrl = await _uploadImageToImgBB(_selectedImage!);
          if (imageUrl == null) throw Exception("Image upload failed");
        }

        final postDoc = postsRef.doc();
        await postDoc.set({
          'text': _text_controller.text.trim(),
          'imageUrl': imageUrl,
          'timestamp': Timestamp.now(),
        });

        await stepsRef.add({
          'step': challengeStep!,
          'timestamp': Timestamp.now(),
        });

        await userRef.update({
          'points': FieldValue.increment(challengePoints!),
          'completedChallenges': FieldValue.increment(1),
          'streak': FieldValue.increment(1),
        });

        if (!mounted) return;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Post created!")),
          );
        });
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.of(context).pop();
        });

      } catch (e) {
        print("Post creation failed: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to create post.")),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }


    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text("Create Post",style: TextStyle(color: Color(0xFF10B981),fontSize: 20,fontFamily: 'Dosis',fontWeight: FontWeight.bold),)),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _text_controller,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Color(0xFFE9FBF4),
                    labelText: "Share your challenge",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _selectedImage != null
                    ? Image.file(_selectedImage!, height: 200)
                    : const SizedBox(),
                TextButton.icon(
                  icon: const Icon(Icons.image,color: Color(0xFF109B981),),
                  label: const Text("Upload Image",style: TextStyle(color: Color(0xFF109B981), fontFamily: 'Dosis'),),
                  onPressed: _pickImage,
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _create_post,
                  child: const Text("Post",style: TextStyle(color: Color(0xFF109B981), fontFamily: 'Dosis'),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
}
