import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';


class App_Bar extends StatefulWidget implements PreferredSizeWidget {
  const App_Bar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<App_Bar> createState() => _App_BarState();
}

class _App_BarState extends State<App_Bar> {
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/step_in');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logout failed: ${e.toString()}'))
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 24,
            fontFamily: 'Dosis',
            fontWeight: FontWeight.w700,
          ),
          children: [
            TextSpan(
              text: 'Step',
              style: TextStyle(color: Color(0xFF000000)),
            ),
            TextSpan(
              text: 'In',
              style: TextStyle(color: Color(0xFF10B981)),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: _isLoggingOut
              ? const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          )
              : const Icon(Icons.logout, color: Color(0xFF10B981),),
          onPressed: _logout,
          tooltip: 'Logout',
        ),
      ],
    );
  }
}