import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'sign_up.dart';

class step_in extends StatefulWidget {
  @override
  _step_inState createState() => _step_inState();
}

class _step_inState extends State<step_in> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => home_screen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        case 'user-not-found':
          errorMessage = 'No account found for this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        default:
          errorMessage = 'Login failed. ${e.code}';
      }
      setState(() => _errorMessage = errorMessage);
    } catch (e) {
      setState(() => _errorMessage = 'An unexpected error occurred');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 450,
              minHeight: MediaQuery.of(context).size.height - 32,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 10, left: 20),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 200,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 50,
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
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontFamily: 'Dosis',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Container(
                  width: 400,
                  margin: const EdgeInsets.only(top: 40, bottom: 30, left: 0),
                  child: TextField(
                    controller: _emailController,
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 16,
                      fontFamily: 'Dosis',
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: InputDecoration(
                      hintText: 'email',
                      hintStyle: TextStyle(color: Color(0xFF6B7280).withOpacity(0.5)),
                      filled: true,
                      fillColor: Color(0xFFE9FBF4),
                      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(70),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 0, bottom: 10, left: 0),
                  width: 400,
                  child: TextField(
                    controller: _passwordController,
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 16,
                      fontFamily: 'Dosis',
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: InputDecoration(
                      hintText: 'password',
                      hintStyle: TextStyle(color: Color(0xFF6B7280).withOpacity(0.5)),
                      filled: true,
                      fillColor: Color(0xFFE9FBF4),
                      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(70),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    obscureText: true,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.only(top: 0, bottom: 20, left: 0),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE9FBF4),
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(70),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                    )
                        : RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: 'Dosis',
                          fontWeight: FontWeight.w900,
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
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 18,
                        fontFamily: 'Dosis',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => StepUp()),
                        );
                      },
                      child: Text(
                        "Create one",
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
    );
  }
}