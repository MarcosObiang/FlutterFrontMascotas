// screens/ajustes_screen.dart
import 'package:flutter/material.dart';
import 'package:mascotas_citas/Dialogs/PresentationDialogs.dart';
import 'package:mascotas_citas/Modules/ProfileModule/state/settingsState.dart';
import 'package:mascotas_citas/Modules/ProfileModule/usecases/LogOutUseCase.dart';
import 'package:mascotas_citas/dependencies/injector.dart';
import 'package:mascotas_citas/interfaces/usecase_interface.dart';
import 'package:provider/provider.dart';
import '../../../Resources/Services/api_service.dart';
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
  final ApiService _apiService = ApiService();
  bool _notificacionesActivas = true;
  double _distanciaMaxima = 20.0;
  String _especieSeleccionada = 'Todas';

  // Opciones de especies
  final List<String> _opcionesEspecies = [
    'Todas',
    'Perro',
    'Gato',
    'Ave',
    'Conejo',
    'Hamster',
    'Otro'
  ];

  @override
  void initState() {
    super.initState();
    // Cargar preferencias guardadas del usuario
    _cargarPreferencias();
  }

  // Método para cargar preferencias (simulado)
  void _cargarPreferencias() {
    // En una implementación real, aquí cargaríamos las preferencias
    // desde SharedPreferences o desde la API
    setState(() {
      _distanciaMaxima = 20.0;
      _especieSeleccionada = 'Todas';
      _notificacionesActivas = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos la instancia del ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);
    UseCaseInterfacae<bool> logOutUseCase = getIt<LogOutUseCase>();

    return ChangeNotifierProvider.value(
      value: getIt<Settingsstate>(),
      child: Consumer<Settingsstate>(builder: (context, settingsState, child) {
        settingsState.onError =
            ({required String message, required String title}) {
          PresentationDialogs().showErrorDialog(
              title: title, content: message, context: context);

          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text(message)),
          // );
        };
        return Scaffold(
          appBar: AppBar(
            title:
                Text('Ajustes', style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: () {
                  // Guardar todos los ajustes
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Configuración guardada')),
                  );
                },
                child:
                    const Text('Guardar', style: TextStyle(color: Colors.pink)),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _construirSeccion('Notificaciones'),
                SwitchListTile(
                  title: Text('Activar notificaciones'),
                  subtitle: Text('Recibe alertas sobre matches y mensajes'),
                  value: _notificacionesActivas,
                  activeColor: Colors.pink,
                  onChanged: (bool value) {
                    setState(() {
                      _notificacionesActivas = value;
                    });
                  },
                ),
                Divider(),

                _construirSeccion('Apariencia'),
                SwitchListTile(
                  title: Text('Modo oscuro'),
                  subtitle: Text('Cambia el tema de la aplicación'),
                  value: themeProvider
                      .isDarkMode, // Usamos el valor del ThemeProvider
                  activeColor: Colors.pink,
                  onChanged: (bool value) {
                    themeProvider
                        .toggleTheme(); // Cambiamos el tema usando el ThemeProvider
                  },
                ),
                Divider(),

                _construirSeccion('Criterios de Búsqueda'),

                // Distancia máxima
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distancia máxima: ${_distanciaMaxima.toInt()} km',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.pink),
                        Expanded(
                          child: Slider(
                            value: _distanciaMaxima,
                            min: 1,
                            max: 100,
                            divisions: 99,
                            activeColor: Colors.pink,
                            inactiveColor: Colors.pink.withOpacity(0.2),
                            label: '${_distanciaMaxima.toInt()} km',
                            onChanged: (double value) {
                              setState(() {
                                _distanciaMaxima = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('1 km', style: TextStyle(color: Colors.grey)),
                        Text('100 km', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Selector de especie
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Especie',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _opcionesEspecies.map((especie) {
                        return ChoiceChip(
                          label: Text(especie),
                          selected: _especieSeleccionada == especie,
                          selectedColor: Colors.pink.withOpacity(0.6),
                          backgroundColor: Colors.pink.withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: _especieSeleccionada == especie
                                ? Colors.white
                                : null,
                            fontWeight: _especieSeleccionada == especie
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _especieSeleccionada = especie;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Divider(),

                _construirSeccion('Cuenta'),
                ListTile(
                  title: Text('Cambiar contraseña'),
                  leading: Icon(Icons.key, color: Colors.pink),
                  onTap: () {
                    // Implementar lógica para cambiar contraseña
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.pink.withOpacity(0.2)),
                  ),
                  tileColor:
                      Theme.of(context).cardColor, // Usamos el color del tema
                ),
                SizedBox(height: 16),

                ListTile(
                  title: Text('Cerrar Sesión'),
                  leading: const Icon(Icons.logout, color: Colors.pink),
                  onTap: () {
                    _cerrarSesion(logOutUseCase);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.pink.withOpacity(0.2)),
                  ),
                  tileColor:
                      Theme.of(context).cardColor, // Usamos el color del tema
                ),
                SizedBox(height: 16),

                ListTile(
                  title: Text('Eliminar cuenta',
                      style: TextStyle(color: Colors.red)),
                  leading: Icon(Icons.delete_forever, color: Colors.red),
                  onTap: () {
                    _mostrarDialogoEliminarCuenta();
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.red.withOpacity(0.2)),
                  ),
                  tileColor:
                      Theme.of(context).cardColor, // Usamos el color del tema
                ),

                SizedBox(height: 30),

                // Información adicional
                Center(
                  child: Column(
                    children: [
                      Text(
                        'ID de Usuario: ${widget.userId}',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Versión 1.0.0',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Guardar todos los ajustes
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Configuración guardada')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('Guardar cambios',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
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
          title: Text('Eliminar cuenta'),
          content: Text(
            '¿Estás seguro que deseas eliminar tu cuenta? Esta acción no se puede deshacer y perderás todos tus datos.',
            style: TextStyle(color: Colors.red.shade800),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Implementar lógica para eliminar cuenta
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
              child: Text('Eliminar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Método para cerrar sesión
  void _cerrarSesion(UseCaseInterfacae<bool> logOutUseCase) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cerrar Sesión'),
          content: Text('¿Estás seguro que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el diálogo
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Cerrar el diálogo
                Navigator.pop(context);
                bool result = await logOutUseCase.execute();
                if (result) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Authscreen()),
                    (route) => false,
                  );
                  // Mostrar mensaje de éxito
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sesión cerrada con éxito')),
                  );
                } else {
                  // Mostrar mensaje de error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al cerrar sesión')),
                  );
                }

                // Navegar a la pantalla de login y eliminar todas las rutas anteriores
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
              ),
              child:
                  Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
