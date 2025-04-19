// widgets/burbuja_mensaje.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BurbujaMensaje extends StatelessWidget {
  final String mensaje;
  final bool esMio;
  final DateTime fecha;
  
  const BurbujaMensaje({
    super.key,
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
          bottom: 16,
          left: esMio ? 50 : 0,
          right: esMio ? 0 : 50,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: esMio ? Colors.pink[100] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mensaje,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4),
            Text(
              _formatearFecha(fecha),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);
    
    if (diferencia.inMinutes < 1) {
      return 'Ahora';
    } else if (diferencia.inHours < 1) {
      return 'Hace ${diferencia.inMinutes} min';
    } else if (diferencia.inDays < 1 && ahora.day == fecha.day) {
      return DateFormat('HH:mm').format(fecha);
    } else if (diferencia.inDays < 7) {
      return DateFormat('E HH:mm').format(fecha);
    } else {
      return DateFormat('dd/MM/yyyy').format(fecha);
    }
  }
}