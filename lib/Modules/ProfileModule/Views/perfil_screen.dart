// pantallas/perfil_screen.dart
import 'package:flutter/material.dart';
import '../../../Resources/Widgets/edit_campo_texto.dart';
import '../../../Resources/Widgets/selector_fotos.dart';
import 'package:mascotas_citas/models/PetModel.dart';
import 'package:mascotas_citas/services/ApiService.dart';
import 'ajustes_screen.dart';
import 'package:mascotas_citas/services/auth/AuthSesionDataService.dart';
import 'package:mascotas_citas/services/platform/storage/SecureStorage.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  // Declarar userId como late para inicializarlo en initState
  late String userId;
  
  // Servicio API
  final ApiService _apiService = ApiService(
    authDataService: AuthDataService(secureStorage: SecureStorage()),
  );
  
  // Instancia del servicio de autenticación
  final AuthDataService _authDataService = AuthDataService(
    secureStorage: SecureStorage()
  );
  
  // Datos del usuario
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userAgeController = TextEditingController();
  final TextEditingController _userSexController = TextEditingController();
  final TextEditingController _userLocationController = TextEditingController();
  final TextEditingController _userBioController = TextEditingController();
  String userImage = 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1000';
  
  // Lista de mascotas mock
  List<PetModel> pets = [];
  
  int selectedPetIndex = 0;
  bool isLoading = true;
  bool isSaving = false; // Flag para indicar cuando se están guardando los datos
  bool useFallbackData = false; // Flag para indicar si estamos usando datos de respaldo
  
  // Controllers para la mascota actual
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _speciesController;
  late TextEditingController _sexController;
  late TextEditingController _bioController;
  late List<String> petImages;
  
@override
void initState() {
  super.initState();
  
  // Inicializar controladores con valores vacíos
  _nameController = TextEditingController();
  _ageController = TextEditingController();
  _speciesController = TextEditingController();
  _sexController = TextEditingController();
  _bioController = TextEditingController();
  petImages = [];
  
  // Cargar y mostrar datos almacenados
  _authDataService.loadStoredData().then((_) {
    // Ahora obtenemos el userId después de cargar los datos
    setState(() {
      userId = _authDataService.getUserUID() ?? '';
      // Limpiar posibles espacios en blanco que pudieran causar errores
      userId = userId.trim();
      print('User ID después de cargar: "$userId"');
    });
    
    // Obtener y mostrar todos los datos de autenticación
    String? token = _authDataService.getToken();
    String? refreshToken = _authDataService.getRefreshToken();
    DateTime? expDate = _authDataService.getExpirationDate();
    
    // Imprimir todos los datos para depuración
    print('======= DATOS DE AUTENTICACIÓN =======');
    print('User ID: "$userId"');
    print('Token: "${token ?? "no hay token"}"');
    print('Refresh Token: "${refreshToken ?? "no hay refresh token"}"');
    print('Fecha Expiración: ${expDate?.toString() ?? "no hay fecha"}');
    print('=====================================');
    
    // Si no hay ID de usuario, mostrar un error o redirigir al login
    if (userId.isEmpty) {
      print('No se encontró ID de usuario, es posible que no haya iniciado sesión');
      setState(() {
        useFallbackData = true;
      });
    }
    
    // Cargar solo los datos del usuario
    _loadUserData();
    // Cargar datos mock para mascotas
    _loadMockPetsData();
  });
}
  
// Método para cargar datos del usuario usando ID específico
Future<void> _getUserById() async {
  try {
    // Verificar que el ID del usuario es válido antes de usarlo
    if (userId.isEmpty) {
      throw Exception('ID de usuario no válido');
    }
    
    // Validar longitud del ID para evitar errores en el backend
    // Si el backend espera IDs de cierta longitud, asegurarnos de que cumplan
    if (userId.length < 6) {
      throw Exception('ID de usuario demasiado corto');
    }
    
    // Hacer la petición al endpoint de usuario específico
    final userResponse = await _apiService.get(
      path: '/users/get-user-data',
      queryParams: {'userUID': userId}, // Usar ID del usuario actual
    );
    
    if (userResponse.statusCode == 200) {
      final userData = userResponse.data;
      
      // Actualizar controladores con datos del usuario
      setState(() {
        _userNameController.text = userData['name'] ?? '';
        _userAgeController.text = userData['age'] != null 
            ? "${userData['age']}" 
            : "${DateTime.now().difference(DateTime.parse(userData['birthDate'] ?? DateTime.now().toString())).inDays ~/ 365}";
        _userSexController.text = userData['sex'] ?? '';
        
        // Verificamos si location viene como un objeto con coordinates
        if (userData['location'] != null && userData['location']['coordinates'] != null) {
          _userLocationController.text = "${userData['location']['coordinates'][1]}, ${userData['location']['coordinates'][0]}";
        } else {
          _userLocationController.text = "No disponible";
        }
        
        _userBioController.text = userData['userBio'] ?? '';
        if (userData['userImage1'] != null && userData['userImage1'].isNotEmpty) {
          userImage = userData['userImage1'];
        }
      });
      
      return userData;
    } else {
      throw Exception('Error al obtener el usuario: ${userResponse.statusCode}');
    }
  } catch (e) {
    print('Error al obtener el usuario: $e');
    throw e;
  }
}

// Método para usar datos de fallback cuando hay problemas
void _setFallbackUserData() {
  setState(() {
    _userNameController.text = 'Usuario Temporal';
    _userAgeController.text = '25';
    _userSexController.text = 'No especificado';
    _userLocationController.text = 'No disponible';
    _userBioController.text = 'Por favor, completa tu perfil cuando se resuelvan los problemas de conexión.';
    userImage = 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1000';
    useFallbackData = true;
  });
}

// Método para cargar datos mock para mascotas
void _loadMockPetsData() {
  // Crear mascotas de prueba
  List<PetModel> mockPets = [
    PetModel(
      id: 'mock_1',
      petUID: 'mock_pet_1',
      onwerUID: userId,
      name: 'Firulais',
      petImage1: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?q=80&w=1000',
      sex: 'Macho',
      petBio: 'Un perro juguetón y amigable que adora correr en el parque.',
      birthDate: DateTime.now().subtract(Duration(days: 365 * 3)), // 3 años
      spicies: 'Perro',
    ),
    PetModel(
      id: 'mock_2',
      petUID: 'mock_pet_2',
      onwerUID: userId,
      name: 'Michi',
      petImage1: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?q=80&w=1000',
      sex: 'Hembra',
      petBio: 'Una gata elegante y un poco caprichosa. Le encanta dormir al sol.',
      birthDate: DateTime.now().subtract(Duration(days: 365 * 2)), // 2 años
      spicies: 'Gato',
    )
  ];
  
  setState(() {
    pets = mockPets;
    if (pets.isNotEmpty) {
      _loadPetData(0);
    }
  });
}

// Método para cargar solo datos del usuario desde la API
Future<void> _loadUserData() async {
  setState(() {
    isLoading = true;
  });
  
  try {
    // Intentamos cargar los datos del usuario
    try {
      await _getUserById();
      setState(() {
        useFallbackData = false;
      });
    } catch (e) {
      print('Error al cargar usuario, usando datos de respaldo: $e');
      _setFallbackUserData();
    }
    
    setState(() {
      isLoading = false;
    });
  } catch (e) {
    print('Error general al cargar datos: $e');
    setState(() {
      isLoading = false;
      useFallbackData = true;
    });
    
    // Mostrar mensaje de error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al cargar datos. Usando datos temporales.'),
        duration: Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Reintentar',
          onPressed: () {
            _loadUserData();
          },
        ),
      )
    );
  }
}
  
  void _loadPetData(int index) {
    if (pets.isEmpty) return;
    
    PetModel pet = pets[index];
    _nameController.text = pet.name;
    _ageController.text = "${DateTime.now().difference(pet.birthDate).inDays ~/ 365}";
    _speciesController.text = pet.spicies;
    _sexController.text = pet.sex;
    _bioController.text = pet.petBio;
    
    // Convertir imágenes en lista
    petImages = [];
    if (pet.petImage1.isNotEmpty) {
      petImages.add(pet.petImage1);
    }
  }
  
  void _saveCurrentPetData() {
    if (pets.isEmpty) return;
    
    // Convertir edad a fecha de nacimiento aproximada
    int years = int.tryParse(_ageController.text) ?? 0;
    DateTime approximateBirthDate = DateTime.now().subtract(Duration(days: years * 365));
    
    // Obtener ID existente o crear uno nuevo
    String currentId = pets[selectedPetIndex].id;
    String currentPetUID = pets[selectedPetIndex].petUID.isNotEmpty ? 
                          pets[selectedPetIndex].petUID : 
                          'mascota_${DateTime.now().millisecondsSinceEpoch}';
    
    // Crear la mascota actualizada
    PetModel updatedPet = PetModel(
      id: currentId,
      petUID: currentPetUID,
      onwerUID: userId,
      name: _nameController.text,
      petImage1: petImages.isNotEmpty ? petImages[0] : '',
      sex: _sexController.text,
      petBio: _bioController.text,
      birthDate: approximateBirthDate,
      spicies: _speciesController.text,
    );
    
    setState(() {
      // Actualizar la mascota actual
      pets[selectedPetIndex] = updatedPet;
    });
  }
  
  void _changePet(int index) {
    // Guardar datos de la mascota actual antes de cambiar
    _saveCurrentPetData();
    
    setState(() {
      selectedPetIndex = index;
      _loadPetData(index);
    });
  }
  
  void _addNewPet() {
    // Guardar datos de la mascota actual si existe
    if (pets.isNotEmpty) {
      _saveCurrentPetData();
    }
    
    // Crear nueva mascota mock
    PetModel newPet = PetModel(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      petUID: 'mock_pet_${DateTime.now().millisecondsSinceEpoch}',
      onwerUID: userId,
      name: '',
      petImage1: '',
      sex: '',
      petBio: '',
      birthDate: DateTime.now(),
      spicies: '',
    );
    
    setState(() {
      pets.add(newPet);
      selectedPetIndex = pets.length - 1;
      
      // Limpiar los controladores para la nueva mascota
      _nameController.text = '';
      _ageController.text = '0';
      _speciesController.text = '';
      _sexController.text = '';
      _bioController.text = '';
      petImages = [];
    });
  }
  
  void _deleteCurrentPet() {
    if (pets.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debes tener al menos una mascota')),
      );
      return;
    }
    
    setState(() {
      pets.removeAt(selectedPetIndex);
      selectedPetIndex = 0;
      _loadPetData(selectedPetIndex);
    });
    
    // No hacemos llamada a la API para eliminar, solo mostramos un mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mascota eliminada localmente (modo demo)')),
    );
  }
  
  void _updateUserPhoto() {
    // Aquí iría la lógica para seleccionar una nueva foto
    // Por simplicidad, solo cambiamos a una foto predefinida
    setState(() {
      userImage = 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=1000';
    });
  }
  
  // Método simulado para guardar datos del usuario
  Future<void> _saveAllData() async {
  if (isSaving) return; // Evitar múltiples guardados simultáneos
  
  setState(() {
    isSaving = true;
  });
  
  try {
    // Guardar la mascota actual antes de enviar
    if (pets.isNotEmpty) {
      _saveCurrentPetData();
    }
    
    // Usar el ID del usuario actual si está disponible, de lo contrario usar ID de prueba
    final String idToUse = userId.isNotEmpty ? userId : '6e1503251f';
    
    // Solo guardamos los datos del usuario
    await _apiService.post(
      path: '/users/update',
      data: {
        'userUID': idToUse,
        'userBio': _userBioController.text,
        'userImage1': userImage,
      },
    ).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Perfil de usuario actualizado. Datos de mascotas guardados localmente.')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar perfil: $error. Datos guardados localmente.')),
      );
    });
    
  } catch (e) {
    print('Error al guardar datos: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al guardar datos: $e. Los cambios se han guardado localmente.')),
    );
  } finally {
    setState(() {
      isSaving = false;
    });
  }
}
  
  // Método para mostrar la pantalla de ajustes
  void _showSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AjustesScreen(
          userId: userId,
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // Determinar si hay mascotas registradas
    final bool hasPets = pets.isNotEmpty;
    
    return Scaffold(      
      appBar: AppBar(
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
                onPressed: _saveAllData,
                child: Text('Guardar', style: TextStyle(color: Colors.pink)),
              ),
        ],
      ),
      body: isLoading 
        ? Center(child: CircularProgressIndicator(color: Colors.pink))
        : SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner de modo de datos de respaldo si estamos usando datos temporales
              if (useFallbackData)
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade700),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Modo de datos temporales',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ),
                            Text(
                              'Usando datos temporales debido a problemas de conexión.',
                              style: TextStyle(
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _loadUserData,
                        child: Text('Reintentar'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Banner informativo sobre datos mock de mascotas
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade700),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade900),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Modo de desarrollo',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          Text(
                            'Usando datos de mascotas de prueba. Solo se guardarán cambios al perfil de usuario.',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
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
                    onPressed: _showSettings,
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
                    onTap: _updateUserPhoto,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(userImage),
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
                        _showNonEditableField('Nombre', _userNameController.text, Icons.person),
                        
                        // Mostrar sexo (no editable)
                        _showNonEditableField('Sexo', _userSexController.text, Icons.person_outline),
                        
                        // Mostrar edad (no editable)
                        _showNonEditableField('Edad', _userAgeController.text, Icons.cake),
                        
                        // Mostrar ubicación (no editable)
                        _showNonEditableField('Ubicación', _userLocationController.text, Icons.location_on),
                        
                        // Bio (editable)
                        EditCampoTexto(
                          label: 'Biografía',
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
              if (!hasPets)
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
                        '¡Añade tu primera mascota!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink.shade800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Una vez que registres tu mascota, podrás acceder a todas las funciones como encontrar amigos para tu mascota.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.pink.shade700),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _addNewPet,
                        icon: Icon(Icons.add, color: Colors.white),
                        label: Text('Añadir mascota', style: TextStyle(color: Colors.white)),
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
              if (hasPets) ...[
                // Selector de mascotas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mis Mascotas (Demo)',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _addNewPet,
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
  height: 90, // Un poco más alto para evitar desbordamientos
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: pets.length,
    itemBuilder: (context, index) {
      return GestureDetector(
        onTap: () => _changePet(index),
        child: Container(
          width: 70, // Ancho fijo para evitar problemas de layout
          margin: EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: index == selectedPetIndex ? Colors.pink : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: pets[index].petImage1.isNotEmpty
                  ? Image.network(
                      pets[index].petImage1,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 50,
                      width: 50,
                      color: Colors.grey[300],
                      child: Icon(Icons.pets, color: Colors.grey[600], size: 24),
                    ),
              ),
              SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  pets[index].name.isEmpty ? 'Nueva' : pets[index].name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: index == selectedPetIndex ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis, // Evita desbordamiento de texto
                  maxLines: 1,
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
                      'Detalles de ${_nameController.text.isEmpty ? "Nueva Mascota" : _nameController.text}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: _deleteCurrentPet,
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
                  fotos: petImages,
                  maxFotos: 3,
                  onFotoPrincipalChanged: (newMainPhoto) {
                    if (petImages.isNotEmpty && petImages.contains(newMainPhoto)) {
                      setState(() {
                        // Mover la foto principal al inicio de la lista
                        petImages.remove(newMainPhoto);
                        petImages.insert(0, newMainPhoto);
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
                  controller: _nameController,
                  icon: Icons.pets,
                ),
                SizedBox(height: 8),
                EditCampoTexto(
                  label: 'Edad (años)',
                  controller: _ageController,
                  icon: Icons.cake,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 8),
                EditCampoTexto(
                  label: 'Especie',
                  controller: _speciesController,
                  icon: Icons.category,
                ),
                SizedBox(height: 8),
                EditCampoTexto(
                  label: 'Sexo',
                  controller: _sexController,
                  icon: Icons.transgender,
                ),
                SizedBox(height: 8),
                EditCampoTexto(
                  label: 'Biografía',
                  controller: _bioController,
                  icon: Icons.description,
                  maxLines: 3,
                ),
                SizedBox(height: 32),
                
                // Botón de guardar (solo visible si hay cambios pendientes)
                Container(
                  width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveAllData,
            child: Text(
              isSaving ? 'Guardando...' : 'Guardar cambios',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
SizedBox(height: 24),
              ],
            ],
          ),
        ),
    );
  }
  
  Widget _showNonEditableField(String label, String value, IconData icon) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        SizedBox(width: 8),
        Expanded(  // Asegura que el texto no desborde
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,  // Maneja texto largo
              ),
              Text(
                value.isEmpty ? 'No especificado' : value,
                style: TextStyle(
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,  // Maneja texto largo
                maxLines: 2,  // Permite hasta 2 líneas antes de mostrar ellipsis
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _userNameController.dispose();
    _userAgeController.dispose();
    _userSexController.dispose();
    _userLocationController.dispose();
    _userBioController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _speciesController.dispose();
    _sexController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}