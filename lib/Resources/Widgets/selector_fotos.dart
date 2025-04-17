// widgets/selector_fotos.dart
import 'package:flutter/material.dart';

class SelectorFotos extends StatelessWidget {
  final List<String> fotos;
  
  const SelectorFotos({super.key, required this.fotos});
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: fotos.length + 1, // +1 para el botón de añadir
        itemBuilder: (context, index) {
          if (index == fotos.length) {
            // Botón para añadir nueva foto
            return _construirBotonAnadir();
          } else {
            // Fotos existentes
            return _construirTarjetaFoto(fotos[index], index);
          }
        },
      ),
    );
  }
  
  Widget _construirTarjetaFoto(String foto, int index) {
    return Container(
      width: 100,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              foto,
              width: 100,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
            ),
          ),
          if (index == 0)
            Positioned(
              bottom: 5,
              left: 5,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.pink,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Principal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _construirBotonAnadir() {
    return Container(
      width: 100,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined, color: Colors.grey),
          SizedBox(height: 4),
          Text(
            'Añadir foto',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}