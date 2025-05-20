// screens/ajustes_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../AuthenticationModule/views/AuthScreen.dart';
import 'package:mascotas_citas/Resources/providers/theme_provider.dart';
import '../component/configuracion_busqueda_provider.dart';

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
  String _especieSeleccionada = 'Todas';
  List<String> _opcionesEspecies = [];
  double _distanciaMaxima = 20.0;
  bool _notificacionesActivas = true;
  TipoBusqueda _tipoBusquedaSeleccionado = TipoBusqueda.todas;
  
  // Lista de opciones de tipo de búsqueda para mostrar en el dropdown
  final List<String> _opcionesTipoBusqueda = [
    'Todas las mascotas',
    'Por proximidad',
    'Por especie',
  ];

  @override
  void initState() {
    super.initState();
    _cargarPreferenciasDesdeProvider();
  }
  
  // Cargar preferencias desde el Provider
  void _cargarPreferenciasDesdeProvider() {
    // Esperamos al primer frame para asegurarnos que el Provider esté disponible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final configProvider = Provider.of<ConfiguracionBusquedaProvider>(context, listen: false);
      
      setState(() {
        _especieSeleccionada = configProvider.especieSeleccionada;
        _distanciaMaxima = configProvider.distanciaMaxima;
        _notificacionesActivas = configProvider.notificacionesActivas;
        _tipoBusquedaSeleccionado = configProvider.tipoBusquedaSeleccionado;
        _opcionesEspecies = configProvider.getEspeciesDisponibles();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos la instancia del ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final configProvider = Provider.of<ConfiguracionBusquedaProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () async {
              // Guardar todos los ajustes usando el provider
              await configProvider.guardarPreferencias();
              if (!mounted) return;
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuración guardada')),
              );
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.pink)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _construirSeccion('Notificaciones'),
            SwitchListTile(
              title: const Text('Activar notificaciones'),
              subtitle: const Text('Recibe alertas sobre matches y mensajes'),
              value: _notificacionesActivas,
              activeColor: Colors.pink,
              onChanged: (bool value) {
                setState(() {
                  _notificacionesActivas = value;
                  configProvider.setNotificacionesActivas(value);
                });
              },
            ),
            const Divider(),
            
            _construirSeccion('Apariencia'),
            SwitchListTile(
              title: const Text('Modo oscuro'),
              subtitle: const Text('Cambia el tema de la aplicación'),
              value: themeProvider.isDarkMode, // Usamos el valor del ThemeProvider
              activeColor: Colors.pink,
              onChanged: (bool value) {
                themeProvider.toggleTheme(); // Cambiamos el tema usando el ThemeProvider
              },
            ),
            const Divider(),
            
            _construirSeccion('Criterios de Búsqueda'),
            
            // Tipo de búsqueda
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tipo de búsqueda',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: configProvider.nombreTipoBusqueda,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.pink.withOpacity(0.2)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    filled: true,
                    fillColor: Colors.pink.withOpacity(0.05),
                  ),
                  items: _opcionesTipoBusqueda.map((String tipo) {
                    return DropdownMenuItem<String>(
                      value: tipo,
                      child: Text(tipo),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        configProvider.setTipoBusquedaPorNombre(newValue);
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Distancia máxima (visible solo si el tipo de búsqueda es por proximidad)
            if (_deberiaOcultarDistancia(configProvider.tipoBusquedaSeleccionado) == false)
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
                              configProvider.setDistanciaMaxima(value);
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
                  const SizedBox(height: 16),
                ],
              ),
            
            // Selector de especie (visible solo si el tipo de búsqueda es por especie)
            if (_deberiaOcultarEspecie(configProvider.tipoBusquedaSeleccionado) == false)
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
                          color: _especieSeleccionada == especie ? Colors.white : null,
                          fontWeight: _especieSeleccionada == especie ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _especieSeleccionada = especie;
                              configProvider.setEspecieSeleccionada(especie);
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
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
              title: const Text('Eliminar cuenta', style: TextStyle(color: Colors.red)),
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
            
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await configProvider.aplicarCambiosBusqueda();
                  if (!mounted) return;
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Configuración guardada y aplicada')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Guardar cambios', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Método para determinar si se debe ocultar la opción de distancia
  bool _deberiaOcultarDistancia(TipoBusqueda tipoBusqueda) {
    // Solo mostrar si es específicamente por proximidad
    return tipoBusqueda != TipoBusqueda.porProximidad;
  }
  
  // Método para determinar si se debe ocultar la opción de especie
  bool _deberiaOcultarEspecie(TipoBusqueda tipoBusqueda) {
    // Solo mostrar si es específicamente por especie
    return tipoBusqueda != TipoBusqueda.porEspecie;
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
              child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
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
              onPressed: () {
                // Aquí podrías llamar a un servicio de autenticación
                // para realizar el logout en el backend si es necesario
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
              child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}