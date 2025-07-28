import 'package:flutter/material.dart';
import 'package:step_out/screens/create_post.dart';
import 'package:step_out/screens/home_screen.dart';
import 'package:step_out/screens/leaderboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:step_out/screens/profile_screen.dart';
import 'package:step_out/screens/search_screen.dart';
import 'package:step_out/screens/sign_up.dart';
import 'package:step_out/screens/splash_screen.dart';
import 'package:step_out/screens/step_in.dart';
final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

class StepOut extends StatelessWidget {
  const StepOut({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/home',
      routes: {
        '/home': (context) => home_screen(),
        '/leaderboard': (context) => leaderboard_screen(),
        '/search': (context) => search_screen(),
        '/profile': (context) => user_profile_screen(userId: currentUserId,),
        '/step_in': (context) => step_in(),
        '/step_up': (context) => StepUp(),
        '/splash_screen': (context) => splash_screen(),
        '/create_post': (context) => create_post(),
      },
      debugShowCheckedModeBanner: false,
      title: 'StepOut',
      home: splash_screen(),

    );


  }
}