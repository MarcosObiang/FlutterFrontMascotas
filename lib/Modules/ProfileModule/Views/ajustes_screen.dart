// screens/ajustes_screen.dart
import 'package:flutter/material.dart';
import 'package:mascotas_citas/Modules/ProfileModule/usecases/LogOutUseCase.dart';
import 'package:mascotas_citas/dependencies/injector.dart';
import 'package:provider/provider.dart';
import '../../AuthenticationModule/views/AuthScreen.dart';
import 'package:mascotas_citas/Resources/providers/theme_provider.dart';

class AjustesScreen extends StatefulWidget {
  final String userId;

  const AjustesScreen({
    super.key,
    required this.userId,
  });

  @override
  _AjustesScreenState createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  @override
  Widget build(BuildContext context) {
    // Obtenemos la instancia del ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _construirSeccion('Apariencia'),
            SwitchListTile(
              title: const Text('Modo oscuro'),
              subtitle: const Text('Cambia el tema de la aplicación'),
              value:
                  themeProvider.isDarkMode, // Usamos el valor del ThemeProvider
              activeColor: Colors.pink,
              onChanged: (bool value) {
                themeProvider
                    .toggleTheme(); // Cambiamos el tema usando el ThemeProvider
              },
            ),
            const Divider(),

            _construirSeccion('Cuenta'),
            ListTile(
              title: const Text('Cerrar Sesión'),
              leading: const Icon(Icons.logout, color: Colors.pink),
              onTap: _cerrarSesion,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.pink.withOpacity(0.2)),
              ),
              tileColor: Theme.of(context).cardColor,
            ),
            const SizedBox(height: 16),

            ListTile(
              title: const Text('Eliminar cuenta',
                  style: TextStyle(color: Colors.red)),
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              onTap: () {
                _mostrarDialogoEliminarCuenta();
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.red.withOpacity(0.2)),
              ),
              tileColor: Theme.of(context).cardColor,
            ),

            const SizedBox(height: 30),

            // Información adicional
            Center(
              child: Column(
                children: [
                  Text(
                    'ID de Usuario: ${widget.userId}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Versión 1.0.0',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _construirSeccion(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        titulo,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.pink[800],
        ),
      ),
    );
  }

  void _mostrarDialogoEliminarCuenta() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar cuenta'),
          content: Text(
            '¿Estás seguro que deseas eliminar tu cuenta? Esta acción no se puede deshacer y perderás todos tus datos.',
            style: TextStyle(color: Colors.red.shade800),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Aquí sí necesitarías un servicio para eliminar la cuenta
                // pero puedes inyectarlo solo cuando sea necesario
                Navigator.pop(context);

                // Volver al login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Authscreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child:
                  const Text('Eliminar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Método para cerrar sesión
  void _cerrarSesion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el diálogo
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await getIt<LogOutUseCase>().execute();

                Navigator.pop(context);

                // Navegar a la pantalla de login y eliminar todas las rutas anteriores
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Authscreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
              ),
              child: const Text('Cerrar Sesión',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}