// Updated sign up page with email validation, delay user creation, send verification code

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'email_verification_code_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class StepUp extends StatefulWidget {
  const StepUp({super.key});

  @override
  State<StepUp> createState() => _StepUpState();
}

class _StepUpState extends State<StepUp> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String? error;
  Future<void> sendEmail(String  code, String email) async {
    final smtpServer = gmail('ahmed4uashraf@gmail.com', 'kfft suyc yxsu lhdn'); // App Password, not Gmail password

    final message = Message()
      ..from = Address('ahmed4uashraf@gmail.com', 'StepOut Team')
      ..recipients.add(email)
      ..subject = 'Welcome to StepOut!'
      ..text = 'Hi ! 🎉 Thanks for signing up for StepOut. Here is your code $code';

    try {
      final sendReport = await send(message, smtpServer);
      print('✅ Email sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('❌ Email not sent. \n' + e.toString());
    }
  }
  Future<void> checkEmailAndSendCode() async {
    setState(() {
      error = null;
      isLoading = true;
    });

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();

      final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');

      if (!emailRegex.hasMatch(email)) {
        setState(() {
          error = 'Please enter a valid email.';
          isLoading = false;
        });
        return;
      }

      if (password.length < 6) {
        setState(() {
          error = 'Password must be at least 6 characters.';
          isLoading = false;
        });
        return;
      }

      if (password != confirmPassword) {
        setState(() {
          error = 'Passwords do not match.';
          isLoading = false;
        });
        return;
      }

      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        setState(() {
          error = 'Email is already in use.';
          isLoading = false;
        });
        return;
      }

      // Generate 6-digit code
      final random = Random();
      final code = (100000 + random.nextInt(900000)).toString();

      // Store code, password, timestamp
      await FirebaseFirestore.instance
          .collection('email_verifications')
          .doc(email)
          .set({
        'email':email,
        'password':password,
        'code': code,
        'timestamp': FieldValue.serverTimestamp(),

      });

      await sendEmail(code, email);

      // Navigate to verification screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationCodePage(
            email: email,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message;
      });
    } catch (e, stack) {
      print('Unexpected error: $e');
      print('Stack trace: $stack');
      setState(() {
        error = 'An unexpected error occurred.';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }


  Widget buildTextField({
    required String hintText,
    required TextEditingController controller,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      width: 400,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 16,
          fontFamily: 'Dosis',
          fontWeight: FontWeight.w800,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: const Color(0xFF6B7280).withOpacity(0.5)),
          filled: true,
          fillColor: const Color(0xFFE9FBF4),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(70),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 10, left: 20),
                    child: Image.asset('assets/images/logo.png', height: 200),
                  ),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 50,
                        fontFamily: 'Dosis',
                        fontWeight: FontWeight.w700,
                      ),
                      children: [
                        TextSpan(text: 'Sign', style: TextStyle(color: Colors.black)),
                        TextSpan(text: 'Up', style: TextStyle(color: Color(0xFF10B981))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  buildTextField(
                    hintText: "email",
                    controller: emailController,
                    validator: (val) =>
                    val != null && !val.contains('@') ? 'Enter a valid email' : null,
                  ),
                  buildTextField(
                    hintText: "password",
                    controller: passwordController,
                    obscure: true,
                  ),
                  buildTextField(
                    hintText: "confirm password",
                    controller: confirmPasswordController,
                    obscure: true,
                    validator: (val) =>
                    val != passwordController.text ? 'Passwords do not match' : null,
                  ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(error!,
                          style: const TextStyle(color: Colors.red, fontFamily: 'Dosis')),
                    ),
                  const SizedBox(height: 10),

                  isLoading
                      ? const SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                    ),
                  )
                      : Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          checkEmailAndSendCode();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE9FBF4),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(70),
                        ),
                      ),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'Dosis',
                            fontWeight: FontWeight.w900,
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign',
                              style: TextStyle(color: Colors.black),
                            ),
                            TextSpan(
                              text: 'Up',
                              style: TextStyle(color: Color(0xFF10B981)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Have an account? ",
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 18,
                          fontFamily: 'Dosis',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          "Sign In",
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Dosis',
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
