import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:step_out/screens/home_screen.dart'; // adjust the import path if needed
import 'package:step_out/screens/step_in.dart';     // adjust the import path if needed

class auth_gate extends StatelessWidget {
  const auth_gate({super.key});
  Future<User?> _getValidUser(User? user) async {
    if(user==null)
      return null;
    try{
      await user.reload();
      return
          FirebaseAuth.instance.currentUser;
    }catch(e)
    {
      await
    FirebaseAuth.instance.signOut();
      return null;
    }
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While checking
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return FutureBuilder<User?>(
          future: _getValidUser(snapshot.data),
          builder: (context, futureSnapshot) {
            if (futureSnapshot.connectionState != ConnectionState.done) {
              return const Scaffold(body: Center(child: CircularProgressIndicator( color: Color(0xFF10B981),
                strokeWidth: 4.0,)));
            }

            final user = futureSnapshot.data;
            if (user != null) {
              return  home_screen(); // or whatever your home page is
            } else {
              return  step_in();
            }
          },
        );
      },
    );
  }
}
