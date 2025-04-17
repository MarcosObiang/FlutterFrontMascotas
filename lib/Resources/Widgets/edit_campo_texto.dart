// widgets/edit_campo_texto.dart
import 'package:flutter/material.dart';

class EditCampoTexto extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType keyboardType;
  
  const EditCampoTexto({super.key, 
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.pink),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.pink, width: 2),
          ),
        ),
      ),
    );
  }
}