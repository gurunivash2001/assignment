 import 'package:flutter/material.dart';
import 'package:test_assignment/screens/Home_screen.dart';
import 'package:test_assignment/screens/tab_home.dart';

class Responsive extends StatefulWidget {
  const Responsive({super.key});

  @override
  State<Responsive> createState() => _ResponsiveState();
}

class _ResponsiveState extends State<Responsive> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: width < 600 ? const HomeScreen() : const TabHome(),
    );
  }
}
