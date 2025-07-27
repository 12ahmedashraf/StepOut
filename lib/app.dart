import 'package:flutter/material.dart';
import 'package:step_out/screens/splash_screen.dart';
class StepOut extends StatelessWidget{
  const StepOut({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StepOut',
      home: splash_screen(),
    );
  }
}