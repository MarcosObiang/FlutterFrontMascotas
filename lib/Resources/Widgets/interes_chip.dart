// widgets/interes_chip.dart
import 'package:flutter/material.dart';

class InteresChip extends StatelessWidget {
  final String texto;
  
  const InteresChip({super.key, required this.texto});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.pink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 12,
          color: Colors.pink,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}