// widgets/boton_accion.dart
import 'package:flutter/material.dart';

class BotonAccion extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  
  const BotonAccion({super.key, 
    required this.icon,
    required this.color,
    required this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 32),
        color: color,
        onPressed: onPressed,
      ),
    );
  }
}