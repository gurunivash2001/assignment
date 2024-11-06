import 'package:flutter/material.dart';

class TopContainers extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final Color color;
  final TextStyle textStyle;

  const TopContainers({
    super.key,
    required this.onTap,
    required this.text,
    required this.color,
    this.textStyle = const TextStyle(color: Colors.white),  
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 70,
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(5), color: color),
        child: Center(
          child: Text(
            text,
            style: textStyle,   
          ),
        ),
      ),
    );
  }
}
