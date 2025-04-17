// widgets/burbuja_mensaje.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BurbujaMensaje extends StatelessWidget {
  final String mensaje;
  final bool esMio;
  final DateTime fecha;
  
  const BurbujaMensaje({super.key, 
    required this.mensaje,
    required this.esMio,
    required this.fecha,
  });
  
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: esMio ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: esMio ? 80 : 0,
          right: esMio ? 0 : 80,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: esMio ? Colors.pink : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mensaje,
              style: TextStyle(
                color: esMio ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(fecha),
              style: TextStyle(
                color: esMio ? Colors.white.withOpacity(0.7) : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}