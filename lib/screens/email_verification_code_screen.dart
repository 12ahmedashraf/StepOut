import 'package:flutter/material.dart';
import 'personal_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerificationCodePage extends StatefulWidget {
  final String email;

  const VerificationCodePage({
    super.key,
    required this.email,
  });

  @override
  State<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {
  final TextEditingController codeController = TextEditingController();
  bool isLoading = false;
  String? error;

  Future<void> verifyCode() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final enteredCode = codeController.text.trim();

    try {
      // Get the verification data from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('email_verifications')
          .doc(widget.email)
          .get();

      if (!doc.exists) {
        setState(() {
          error = "Verification code expired or invalid.";
          isLoading = false;
        });
        return;
      }

      final data = doc.data()!;
      final storedCode = data['code']?.toString();
      final password = data['password']?.toString();

      if (enteredCode != storedCode) {
        setState(() {
          error = "Invalid verification code. Please try again.";
          isLoading = false;
        });
        return;
      }


      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) =>  personal_info_screen(email: widget.email, password: password!)),
      );
      await FirebaseFirestore.instance
          .collection('email_verifications')
          .doc(widget.email)
          .delete();


    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message ?? "Auth error occurred.";
      });
    } catch (e) {
      print("$e");
      setState(() {
        error = "Something went wrong. Please try again.";

      });
    } finally {
      setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final themeGreen = const Color(0xFF10B981);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(color: themeGreen),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Text(
              "Enter Verification Code",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                fontFamily: 'Dosis',
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "We’ve sent a verification code to",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontFamily: 'Dosis'
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.email,
              style: TextStyle(
                fontSize: 16,
                color: themeGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),

            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter code",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: themeGreen),
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  error!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),

            isLoading
                ? const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                ),
              ),
            )
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(fontSize: 16,color: Color(0xFFFFFFFF),fontFamily: 'Dosis'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
