import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'sign_up.dart';
class step_in extends StatefulWidget{
  @override
  _step_inState createState() => _step_inState();
}
class _step_inState extends State<step_in>
{
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  Future<void> _signIn() async{
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => home_screen()));
    }
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 450, // optional, to limit width on wide screens
                minHeight: MediaQuery.of(context).size.height - 32, // full height minus padding
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
                      onPressed: _signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE9FBF4),
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(70),
                        ),
                      ),
                      child: RichText(
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


