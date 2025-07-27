import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'step_in.dart';
import 'dart:async';
import 'package:step_out/auth/auth_gate.dart';

class splash_screen extends StatefulWidget {
  const splash_screen({super.key});

  @override
  State<splash_screen> createState() => _splash_screenState();
}

class _splash_screenState extends State<splash_screen>{
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const auth_gate()),
      );
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 0,left: 20),
            child: Image.asset(
              'assets/images/logo.png',
              height: 300,
            )
            ),
            RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 64,
                    fontFamily: 'Dosis',
                    fontWeight: FontWeight.w700,
                  ),
                  children: [
                      TextSpan(
                        text: 'Step',
                        style: TextStyle(color: Color(0xFF000000))
                      ),
                    TextSpan(
                        text: 'Out',
                        style: TextStyle(color: Color(0xFF10B981))
                    ),
                  ],
                ),
            )
          ],
        ),
      ),
    );
  }
}