// screens/perfil_screen.dart
import 'package:flutter/material.dart';
import '../../../Resources/Widgets/edit_campo_texto.dart';
import '../../../Resources/Widgets/selector_fotos.dart';
import '../../../Resources/Models/mascota_api.dart';
import '../../../Resources/Services/api_service.dart';
import '../../AuthenticationModule/views/AuthScreen.dart';
import 'ajustes_screen.dart'; // Importamos la nueva pantalla de ajustes

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  // ID de usuario estático por ahora
  final String userId = 'cr7erbisho';
  
  // API Service
  final ApiService _apiService = ApiService();
  
  // Datos del usuario
  final TextEditingController _userNombreController = TextEditingController();
  final TextEditingController _userEdadController = TextEditingController();
  final TextEditingController _userSexoController = TextEditingController();
  final TextEditingController _userUbicacionController = TextEditingController();
  final TextEditingController _userBioController = TextEditingController();
  String fotoUsuario = 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1000';
  
  // Lista de mascotas
  List<Mascota> mascotas = [];
  List<String> mascotasOriginalesIds = []; // Para mantener un registro de las mascotas originales
  
  int mascotaSeleccionadaIndex = 0;
  bool isLoading = true;
  bool isSaving = false; // Flag para indicar cuando se están guardando los datos
  
  // Controllers para la mascota actual
  late TextEditingController _nombreController;
  late TextEditingController _edadController;
  late TextEditingController _especieController;
  late TextEditingController _sexoController;
  late TextEditingController _descripcionController;
  late List<String> fotos;
  
  @override
  void initState() {
    super.initState();
    
    // Inicializar controladores con valores vacíos
    _nombreController = TextEditingController();
    _edadController = TextEditingController();
    _especieController = TextEditingController();
    _sexoController = TextEditingController();
    _descripcionController = TextEditingController();
    fotos = [];
    
    // Cargar datos del usuario y sus mascotas
    _cargarDatosUsuarioYMascotas();
  }
  
  // Método para cargar datos del usuario y sus mascotas desde la API
  Future<void> _cargarDatosUsuarioYMascotas() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      // Cargar datos del usuario
      final usuario = await _apiService.getUserById(userId);
      
      // Actualizar controladores con datos del usuario
      setState(() {
        _userNombreController.text = usuario.nombre;
        _userEdadController.text = usuario.edad;
        _userSexoController.text = usuario.sexo;
        _userUbicacionController.text = usuario.ubicacion;
        _userBioController.text = usuario.bio;
        if (usuario.fotoPerfil.isNotEmpty) {
          fotoUsuario = usuario.fotoPerfil;
        }
      });
      
      // Cargar todas las mascotas y filtrar las del usuario actual
      final todasLasMascotas = await _apiService.getAllPets();
      final mascotasUsuario = todasLasMascotas.where((mascota) => 
        mascota.propietarioId == userId).toList();
      
      setState(() {
        mascotas = mascotasUsuario;
        // Guardar los IDs de las mascotas originales para comparar después
        mascotasOriginalesIds = mascotas.map((m) => m.id).toList();
        isLoading = false;
        
        if (mascotas.isNotEmpty) {
          _cargarDatosMascota(0);
        }
      });
    } catch (e) {
      print('Error al cargar datos: $e');
      setState(() {
        isLoading = false;
      });
      
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e'))
      );
    }
  }
  
  void _cargarDatosMascota(int index) {
    if (mascotas.isEmpty) return;
    
    Mascota mascota = mascotas[index];
    _nombreController.text = mascota.nombre;
    _edadController.text = mascota.edad;
    _especieController.text = mascota.especie;
    _sexoController.text = mascota.sexo ?? '';
    _descripcionController.text = mascota.descripcion;
    fotos = List.from(mascota.fotos);
  }
  
  void _guardarDatosMascotaActual() {
    if (mascotas.isEmpty) return;
    
    // Crear la mascota actualizada
    Mascota mascotaActualizada = Mascota(
      id: mascotas[mascotaSeleccionadaIndex].id,
      ownerUID: userId,
      name: _nombreController.text,
      petImage1: fotos.isNotEmpty ? fotos[0] : '',
      petImage2: fotos.length > 1 ? fotos[1] : '',
      petImage3: fotos.length > 2 ? fotos[2] : '',
      sex: _sexoController.text,
      petBio: _descripcionController.text,
      species: _especieController.text,
      birthDate: mascotas[mascotaSeleccionadaIndex].birthDate, // Mantenemos la fecha original
      enAdopcion: mascotas[mascotaSeleccionadaIndex].enAdopcion,
      intereses: [], // Eliminamos los intereses
      propietarioNombre: _userNombreController.text,
      propietarioFoto: fotoUsuario,
      ubicacion: _userUbicacionController.text,
    );
    
    setState(() {
      // Actualizar la mascota actual
      mascotas[mascotaSeleccionadaIndex] = mascotaActualizada;
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
    
    // Crear nueva mascota
    Mascota nuevaMascota = Mascota.empty(
      propietarioId: userId,
      propietarioNombre: _userNombreController.text,
      propietarioFoto: fotoUsuario,
      ubicacion: _userUbicacionController.text,
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
    
    final mascotaAEliminar = mascotas[mascotaSeleccionadaIndex];
    
    setState(() {
      mascotas.removeAt(mascotaSeleccionadaIndex);
      mascotaSeleccionadaIndex = 0;
      _cargarDatosMascota(mascotaSeleccionadaIndex);
    });
    
    // Si la mascota ya existía en la base de datos, la eliminamos
    if (mascotasOriginalesIds.contains(mascotaAEliminar.id)) {
      _apiService.deletePet(mascotaAEliminar.id).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mascota eliminada correctamente')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar mascota: $error')),
        );
      });
    }
  }
  
  void _actualizarFotoUsuario() {
    // Aquí iría la lógica para seleccionar una nueva foto
    // Por simplicidad, solo cambiamos a una foto predefinida
    setState(() {
      fotoUsuario = 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=1000';
    });
  }
  
  // Método para guardar todos los datos (usuario y mascotas)
  Future<void> _guardarTodosLosDatos() async {
    if (isSaving) return; // Evitar múltiples guardados simultáneos
    
    setState(() {
      isSaving = true;
    });
    
    try {
      // Guardar la mascota actual antes de enviar todo
      if (mascotas.isNotEmpty) {
        _guardarDatosMascotaActual();
      }
      
      // 1. Actualizar datos del usuario
      await _apiService.updateUserProfile(
        userId,
        {
          'bio': _userBioController.text,
          'userImage1': fotoUsuario,
          // Solo enviamos los campos editables
          // Los demás campos los mantiene la API como están
        }
      );
      
      // 2. Procesar mascostas: actualizar existentes, crear nuevas
      for (Mascota mascota in mascotas) {
        if (mascotasOriginalesIds.contains(mascota.id)) {
          // Es una mascota existente, actualizar
          await _apiService.updatePet(mascota.id as Map<String, dynamic>);
        } else {
          // Es una mascota nueva, crear
          await _apiService.createPet(mascota as Map<String, dynamic>);
        }
      }
      
      // 3. Buscar mascotas eliminadas (las que estaban en la lista original pero ya no están)
      for (String id in mascotasOriginalesIds) {
        if (!mascotas.any((m) => m.id == id)) {
          // Esta mascota fue eliminada, eliminarla en el servidor
          await _apiService.deletePet(id);
        }
      }
      
      // Actualizar la lista de IDs originales
      mascotasOriginalesIds = mascotas.map((m) => m.id).toList();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Perfil actualizado correctamente')),
      );
    } catch (e) {
      print('Error al guardar datos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar datos: $e')),
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }
  
  // Método para mostrar la pantalla de ajustes
  void _mostrarAjustes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AjustesScreen(
          userId: userId,
          // Podemos pasar más datos si es necesario
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // Determinar si hay mascotas registradas
    final bool tieneMascota = mascotas.isNotEmpty;
    
    return Scaffold(      
      appBar: AppBar(
        // backgroundColor: Color.fromRGBO(242, 217, 208, 1),
        title: Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          isSaving 
            ? Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.pink,
                    strokeWidth: 2.0,
                  ),
                ),
              )
            : TextButton(
                onPressed: _guardarTodosLosDatos,
                child: Text('Guardar', style: TextStyle(color: Colors.pink)),
              ),
        ],
      ),
      // backgroundColor: Color.fromRGBO(242, 217, 208, 1),
      body: isLoading 
        ? Center(child: CircularProgressIndicator(color: Colors.pink))
        : SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Perfil del usuario con botón de ajustes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Datos del Usuario',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.pink),
                    onPressed: _mostrarAjustes,
                    tooltip: 'Ajustes',
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Foto del usuario
                  GestureDetector(
                    onTap: _actualizarFotoUsuario,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(fotoUsuario),
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
                  // Datos del usuario (solo Bio es editable)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mostrar nombre (no editable)
                        _mostrarCampoNoEditable('Nombre', _userNombreController.text, Icons.person),
                        
                        // Mostrar sexo (no editable)
                        _mostrarCampoNoEditable('Sexo', _userSexoController.text, Icons.person_outline),
                        
                        // Mostrar edad (no editable)
                        _mostrarCampoNoEditable('Edad', _userEdadController.text, Icons.cake),
                        
                        // Mostrar ubicación (no editable)
                        _mostrarCampoNoEditable('Ubicación', _userUbicacionController.text, Icons.location_on),
                        
                        // Bio (editable)
                        EditCampoTexto(
                          label: 'Bio',
                          controller: _userBioController,
                          icon: Icons.description,
                          maxLines: 3,
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
                // Ajuste de tamaño para la lista de mascotas
                SizedBox(
                  height: 80, // Reducido de 100 a 80
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: mascotas.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _cambiarMascota(index),
                        child: Container(
                          margin: EdgeInsets.only(right: 12), // Reducido de 16 a 12
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: index == mascotaSeleccionadaIndex ? Colors.pink : Colors.transparent,
                              width: 2, // Reducido de 3 a 2
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: mascotas[index].fotos.isNotEmpty
                                  ? Image.network(
                                      mascotas[index].fotos[0],
                                      height: 50, // Reducido de 70 a 50
                                      width: 50,  // Reducido de 70 a 50
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      height: 50, // Reducido de 70 a 50
                                      width: 50,  // Reducido de 70 a 50
                                      color: Colors.grey[300],
                                      child: Icon(Icons.pets, color: Colors.grey[600], size: 24), // Reducido el tamaño del icono
                                    ),
                              ),
                              SizedBox(height: 2), // Reducido de 4 a 2
                              Text(
                                mascotas[index].nombre.isEmpty ? 'Nueva' : mascotas[index].nombre,
                                style: TextStyle(
                                  fontSize: 12, // Agregado un tamaño más pequeño
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
                  'Fotos de tu mascota (máximo 3)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                SelectorFotos(
                  fotos: fotos,
                  maxFotos: 3,
                  onFotoPrincipalChanged: (nuevaPrincipal) {
                    if (fotos.isNotEmpty && fotos.contains(nuevaPrincipal)) {
                      setState(() {
                        // Mover la foto principal al inicio de la lista
                        fotos.remove(nuevaPrincipal);
                        fotos.insert(0, nuevaPrincipal);
                      });
                    }
                  },
                ),
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
                  label: 'Sexo',
                  controller: _sexoController,
                  icon: Icons.person_outline,
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
              ],
              
              SizedBox(height: 36),
            ],
          ),
        ),
    );
  }
  
  Widget _mostrarCampoNoEditable(String label, String valor, IconData icono) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icono, size: 20, color: Colors.pink),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              valor,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}