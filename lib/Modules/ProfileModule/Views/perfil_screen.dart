// screens/perfil_screen.dart
import 'package:flutter/material.dart';
import '../../../Resources/Widgets/edit_campo_texto.dart';
import '../../../Resources/Widgets/selector_fotos.dart';
import '../../../Resources/Models/mascota.dart';
// Importar la pantalla de login
import '../../AuthenticationModule/views/AuthScreen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  // Datos del dueño comunes
  final TextEditingController _duenioNombreController = TextEditingController(text: 'Ana Rodríguez');
  final TextEditingController _duenioTelefonoController = TextEditingController(text: '555-123-4567');
  final TextEditingController _duenioCorreoController = TextEditingController(text: 'ana.rodriguez@email.com');
  final TextEditingController _duenioUbicacionController = TextEditingController(text: 'Madrid, España');
  String fotoDuenio = 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1000';
  
  // Lista de mascotas
  List<Mascota> mascotas = [
    Mascota(
      enAdopcion: false,
      id: '1',
      nombre: 'Max',
      edad: '3',
      especie: 'Perro',
      raza: 'Golden Retriever',
      descripcion: 'Soy un perro muy activo y juguetón. Me encanta hacer nuevos amigos y jugar en el parque. Busco compañeros de aventuras para paseos y juegos.',
      fotos: [
        'https://images.unsplash.com/photo-1552053831-71594a27632d?q=80&w=1000',
        'https://images.unsplash.com/photo-1587300003388-59208cc962cb?q=80&w=1000',
        'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?q=80&w=1000',
      ],
      propietarioNombre: 'Ana Rodríguez',
      propietarioFoto: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1000',
      ubicacion: 'Madrid, España',
      intereses: ['Paseos', 'Jugar', 'Nadar', 'Socializar'],
    ),
    Mascota(
      enAdopcion: false,
      id: '2',
      nombre: 'Luna',
      edad: '2',
      especie: 'Gato',
      raza: 'Siamés',
      descripcion: 'Soy una gata tranquila y cariñosa. Me encanta dormir en lugares cómodos y cálidos. Busco amigos tranquilos para compartir momentos de relax.',
      fotos: [
        'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?q=80&w=1000',
        'https://images.unsplash.com/photo-1618826411640-d6df44dd3f7a?q=80&w=1000',
      ],
      propietarioNombre: 'Ana Rodríguez',
      propietarioFoto: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1000',
      ubicacion: 'Madrid, España',
      intereses: ['Dormir', 'Jugar con plumas', 'Trepar'],
    ),
  ];
  
  int mascotaSeleccionadaIndex = 0;
  
  // Controllers para la mascota actual
  late TextEditingController _nombreController;
  late TextEditingController _edadController;
  late TextEditingController _especieController;
  late TextEditingController _razaController;
  late TextEditingController _descripcionController;
  late List<String> fotos;
  late List<String> intereses;
  
  @override
  void initState() {
    super.initState();
    
    // Para propósitos de prueba, podemos vaciar la lista de mascotas
    // Descomentar la siguiente línea para probar el banner sin mascotas
    // mascotas = [];
    
    if (mascotas.isNotEmpty) {
      _cargarDatosMascota(mascotaSeleccionadaIndex);
      
      // Inicializar los datos del dueño basados en la primera mascota
      _duenioNombreController.text = mascotas[0].propietarioNombre;
      _duenioUbicacionController.text = mascotas[0].ubicacion;
      fotoDuenio = mascotas[0].propietarioFoto;
    } else {
      // Inicializar controladores con valores vacíos si no hay mascotas
      _nombreController = TextEditingController();
      _edadController = TextEditingController();
      _especieController = TextEditingController();
      _razaController = TextEditingController();
      _descripcionController = TextEditingController();
      fotos = [];
      intereses = [];
    }
  }
  
  void _cargarDatosMascota(int index) {
    if (mascotas.isEmpty) return;
    
    Mascota mascota = mascotas[index];
    _nombreController = TextEditingController(text: mascota.nombre);
    _edadController = TextEditingController(text: mascota.edad);
    _especieController = TextEditingController(text: mascota.especie);
    _razaController = TextEditingController(text: mascota.raza);
    _descripcionController = TextEditingController(text: mascota.descripcion);
    fotos = List.from(mascota.fotos);
    intereses = List.from(mascota.intereses);
  }
  
  void _guardarDatosMascotaActual() {
    if (mascotas.isEmpty) return;
    
    // Actualizar todas las mascotas con la información del dueño
    String nuevoNombreDuenio = _duenioNombreController.text;
    String nuevaUbicacion = _duenioUbicacionController.text;
    
    // Crear la mascota actualizada
    Mascota mascotaActualizada = Mascota(
      enAdopcion: false,
      id: mascotas[mascotaSeleccionadaIndex].id,
      nombre: _nombreController.text,
      edad: _edadController.text,
      especie: _especieController.text,
      raza: _razaController.text,
      descripcion: _descripcionController.text,
      fotos: fotos,
      propietarioNombre: nuevoNombreDuenio,
      propietarioFoto: fotoDuenio,
      ubicacion: nuevaUbicacion,
      intereses: intereses,
    );
    
    setState(() {
      // Actualizar la mascota actual
      mascotas[mascotaSeleccionadaIndex] = mascotaActualizada;
      
      // Actualizar la información del propietario en todas las mascotas
      for (int i = 0; i < mascotas.length; i++) {
        if (i != mascotaSeleccionadaIndex) {
          mascotas[i] = Mascota(
            enAdopcion: false,
            id: mascotas[i].id,
            nombre: mascotas[i].nombre,
            edad: mascotas[i].edad,
            especie: mascotas[i].especie,
            raza: mascotas[i].raza,
            descripcion: mascotas[i].descripcion,
            fotos: mascotas[i].fotos,
            propietarioNombre: nuevoNombreDuenio,
            propietarioFoto: fotoDuenio,
            ubicacion: nuevaUbicacion,
            intereses: mascotas[i].intereses,
          );
        }
      }
    });
  }
  
  void _cambiarMascota(int index) {
    // Guardar datos de la mascota actual antes de cambiar
    _guardarDatosMascotaActual();
    
    setState(() {
      mascotaSeleccionadaIndex = index;
      _cargarDatosMascota(index);
    });
  }
  
  void _agregarNuevaMascota() {
    // Guardar datos de la mascota actual si existe
    if (mascotas.isNotEmpty) {
      _guardarDatosMascotaActual();
    }
    
    // Obtener la información actual del propietario
    String nombreDuenio = _duenioNombreController.text;
    String ubicacionDuenio = _duenioUbicacionController.text;
    
    // Crear nueva mascota
    Mascota nuevaMascota = Mascota(
      enAdopcion: false,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: '',
      edad: '',
      especie: '',
      raza: '',
      descripcion: '',
      fotos: [],
      propietarioNombre: nombreDuenio,
      propietarioFoto: fotoDuenio,
      ubicacion: ubicacionDuenio,
      intereses: [],
    );
    
    setState(() {
      mascotas.add(nuevaMascota);
      mascotaSeleccionadaIndex = mascotas.length - 1;
      _cargarDatosMascota(mascotaSeleccionadaIndex);
    });
  }
  
  void _eliminarMascotaActual() {
    if (mascotas.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debes tener al menos una mascota')),
      );
      return;
    }
    
    setState(() {
      mascotas.removeAt(mascotaSeleccionadaIndex);
      mascotaSeleccionadaIndex = 0;
      _cargarDatosMascota(mascotaSeleccionadaIndex);
    });
  }
  
  void _actualizarFotoDuenio() {
    // Aquí iría la lógica para seleccionar una nueva foto
    // Por simplicidad, solo cambiamos a una foto predefinida
    setState(() {
      fotoDuenio = 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=1000';
    });
  }
  
  // Método para cerrar sesión
  void _cerrarSesion() {
    // Aquí puedes agregar lógica adicional si es necesario
    // Por ejemplo, limpiar tokens de autenticación, datos de usuario, etc.
    
    // Mostrar un diálogo de confirmación
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
              onPressed: () {
                // Cerrar el diálogo
                Navigator.pop(context);
                
                // Navegar a la pantalla de login y eliminar todas las rutas anteriores
               // Navigator.pushAndRemoveUntil(
                  //context,
                  //MaterialPageRoute(builder: (context) => LoginScreen()),
                  //(route) => false, // Esto elimina todas las rutas anteriores
               // );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
              ),
              child: Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // Determinar si hay mascotas registradas
    final bool tieneMascota = mascotas.isNotEmpty;
    
    return Scaffold(      
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(242, 217, 208, 1),
        title: Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              if (tieneMascota) {
                _guardarDatosMascotaActual();
              }
              
              // Aquí podrías guardar los datos en almacenamiento persistente
              // Ejemplo: SharedPreferences, Hive, SQLite, etc.
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Perfil actualizado')),
              );
            },
            child: Text('Guardar', style: TextStyle(color: Colors.pink)),
          ),
        ],
      ),
      backgroundColor: Color.fromRGBO(242, 217, 208, 1),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Perfil del dueño
            Text(
              'Datos del Dueño',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto del dueño
                GestureDetector(
                  onTap: _actualizarFotoDuenio,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(fotoDuenio),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.pink,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                // Datos del dueño
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EditCampoTexto(
                        label: 'Nombre',
                        controller: _duenioNombreController,
                        icon: Icons.person,
                      ),
                      EditCampoTexto(
                        label: 'Teléfono',
                        controller: _duenioTelefonoController,
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      EditCampoTexto(
                        label: 'Correo',
                        controller: _duenioCorreoController,
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      EditCampoTexto(
                        label: 'Ubicación',
                        controller: _duenioUbicacionController,
                        icon: Icons.location_on,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),

            // Mensaje para usuarios sin mascota
            if (!tieneMascota)
              Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.pink.shade100),
                ),
                child: Column(
                  children: [
                    Icon(Icons.pets, size: 40, color: Colors.pink),
                    SizedBox(height: 10),
                    Text(
                      '¡Agrega tu primera mascota!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink.shade800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Una vez que registres tu mascota, podrás acceder a todas las funcionalidades como encontrar amigos para tu mascota.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.pink.shade700),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _agregarNuevaMascota,
                      icon: Icon(Icons.add, color: Colors.white),
                      label: Text('Agregar mascota', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
            // Contenido relacionado con mascotas (solo visible si tiene mascotas)
            if (tieneMascota) ...[
              // Selector de mascotas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mis Mascotas',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _agregarNuevaMascota,
                    icon: Icon(Icons.add, color: Colors.white),
                    label: Text('Nueva mascota', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: mascotas.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _cambiarMascota(index),
                      child: Container(
                        margin: EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: index == mascotaSeleccionadaIndex ? Colors.pink : Colors.transparent,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: mascotas[index].fotos.isNotEmpty
                                ? Image.network(
                                    mascotas[index].fotos[0],
                                    height: 70,
                                    width: 70,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    height: 70,
                                    width: 70,
                                    color: Colors.grey[300],
                                    child: Icon(Icons.pets, color: Colors.grey[600]),
                                  ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              mascotas[index].nombre.isEmpty ? 'Nueva' : mascotas[index].nombre,
                              style: TextStyle(
                                fontWeight: index == mascotaSeleccionadaIndex ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24),
              
              // Detalles de la mascota seleccionada
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detalles de ${_nombreController.text.isEmpty ? "Nueva Mascota" : _nombreController.text}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _eliminarMascotaActual,
                    icon: Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Eliminar mascota',
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Fotos de tu mascota',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              SelectorFotos(fotos: fotos),
              SizedBox(height: 24),
              
              Text(
                'Información básica',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              EditCampoTexto(
                label: 'Nombre',
                controller: _nombreController,
                icon: Icons.pets,
              ),
              EditCampoTexto(
                label: 'Edad',
                controller: _edadController,
                icon: Icons.cake,
                keyboardType: TextInputType.number,
              ),
              EditCampoTexto(
                label: 'Especie',
                controller: _especieController,
                icon: Icons.category,
              ),
              EditCampoTexto(
                label: 'Raza',
                controller: _razaController,
                icon: Icons.pets_outlined,
              ),
              SizedBox(height: 24),
              
              Text(
                'Sobre tu mascota',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _descripcionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Describe a tu mascota...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.pink, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 24),
              
              Text(
                'Intereses',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...intereses.map((interes) => _construirChipInteres(interes)),
                  ActionChip(
                    avatar: Icon(Icons.add, size: 16),
                    label: Text('Añadir'),
                    onPressed: _mostrarDialogoAgregarInteres,
                  ),
                ],
              ),
            ],
            
            SizedBox(height: 36),
            
            Center(
              child: ElevatedButton(
                onPressed: _cerrarSesion, // Llamar al método de cerrar sesión
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Cerrar Sesión',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  Widget _construirChipInteres(String interes) {
    return Chip(
      label: Text(interes),
      onDeleted: () {
        setState(() {
          intereses.remove(interes);
        });
      },
      deleteIcon: Icon(Icons.close, size: 16),
      backgroundColor: Colors.pink.withOpacity(0.1),
      deleteIconColor: Colors.pink,
    );
  }
  
  void _mostrarDialogoAgregarInteres() {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Añadir interés'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Ej: Paseos, Jugar, Nadar...',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  intereses.add(controller.text.trim());
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
            ),
            child: Text('Añadir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}