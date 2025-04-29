// pantallas/perfil_screen.dart
import 'package:flutter/material.dart';
import 'dart:io'; // Para FileImage
import '../../../Resources/Widgets/edit_campo_texto.dart';
import '../../../Resources/Widgets/selector_fotos.dart';
import 'package:mascotas_citas/models/PetModel.dart';
import 'package:mascotas_citas/services/ApiService.dart';
import 'ajustes_screen.dart';
import 'package:mascotas_citas/services/auth/AuthSesionDataService.dart';
import 'package:mascotas_citas/services/platform/storage/SecureStorage.dart';
import 'package:image_picker/image_picker.dart'; // Añadimos la dependencia de image_picker

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
  
  // Lista de mascotas
  List<PetModel> pets = [];
  
  int selectedPetIndex = 0;
  bool isLoading = true;
  bool isSaving = false; // Flag para indicar cuando se están guardando los datos
  
  // Controllers para la mascota actual
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _speciesController;
  late TextEditingController _sexController;
  late TextEditingController _bioController;
  late List<String> petImages;
  
  // Instancia del ImagePicker
  final ImagePicker _picker = ImagePicker();
  
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
      // Para pruebas, podemos usar un ID estático que coincida con nuestro backend local
      userId = 'cr7erbisho'; // ID que corresponde al usuario de prueba en localhost
      print('User ID para pruebas con localhost: "$userId"');
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
    
    // Cargar datos del usuario
    _loadUserData();
    // Cargar datos de mascotas reales
    _loadPetsData();
  });
}
  
// Método para cargar datos del usuario usando ID específico
Future<void> _getUserById() async {
  try {
    // Verificar que el ID del usuario es válido antes de usarlo
    if (userId.isEmpty) {
      throw Exception('ID de usuario no válido');
    }
    
    // Usar el endpoint local especificado
    final userResponse = await _apiService.get(
      path: 'http://localhost:8082/users/get-user-data',
      queryParams: {'userUID': userId}, // Usar ID del usuario actual
    );
    
    if (userResponse.statusCode == 200) {
      final userData = userResponse.data;
      
      // Actualizar controladores con datos del usuario
      setState(() {
        _userNameController.text = userData['name'] ?? '';
        
        // Calcular edad desde birthDate (en milisegundos desde epoch)
        if (userData['birthDate'] != null) {
          // birthDate viene como timestamp en milisegundos
          final birthDate = DateTime.fromMillisecondsSinceEpoch(userData['birthDate']);
          final age = DateTime.now().difference(birthDate).inDays ~/ 365;
          _userAgeController.text = age.toString();
        } else {
          _userAgeController.text = "No disponible";
        }
        
        _userSexController.text = userData['sex'] ?? '';
        
        // Por ahora, no tenemos datos de ubicación en la respuesta
        _userLocationController.text = "No disponible";
        
        _userBioController.text = userData['userBio'] ?? '';
        if (userData['userImage1'] != null && userData['userImage1'].toString().isNotEmpty) {
          userImage = userData['userImage1'];
        }
      });
      
      return userData;
    } else {
      throw Exception('Error al obtener el usuario: ${userResponse.statusCode}');
    }
  } catch (e) {
    print('Error al obtener el usuario: $e');
    rethrow;
  }
}

// Método para cargar los datos reales de las mascotas desde la API
Future<void> _loadPetsData() async {
  try {
    if (userId.isEmpty) {
      throw Exception('ID de usuario no válido');
    }
    
    // Llamada a la API para obtener las mascotas del usuario
    final petsResponse = await _apiService.get(
      path: 'http://localhost:8083/pets/get-pet-data-by-owner',
      queryParams: {'ownerUID': userId},
    );
    
    if (petsResponse.statusCode == 200) {
      // La respuesta es una lista de mascotas
      final List<dynamic> petsData = petsResponse.data;
      List<PetModel> fetchedPets = [];
      
      // Convertir cada objeto de la respuesta a PetModel
      for (var petData in petsData) {
        DateTime birthDate = DateTime.fromMillisecondsSinceEpoch(petData['birthDate'] ?? 0);
        
        PetModel pet = PetModel(
          id: petData['id'] ?? '',
          petUID: petData['petUID'] ?? '',
          ownerUID: petData['ownerUID'] ?? '',
          name: petData['name'] ?? '',
          petImage1: petData['petImage1'] ?? '',
          petImage2: petData['petImage2'],
          petImage3: petData['petImage3'],
          sex: petData['sex'] ?? '',
          petBio: petData['petBio'] ?? '',
          birthDate: birthDate,
          species: petData['species'] ?? '',
        );
        fetchedPets.add(pet);
      }
      
      setState(() {
        pets = fetchedPets;
        if (pets.isNotEmpty) {
          _loadPetData(0);
        }
      });
      
      print('Mascotas cargadas correctamente: ${pets.length}');
    } else {
      throw Exception('Error al obtener mascotas: ${petsResponse.statusCode}');
    }
  } catch (e) {
    print('Error al cargar mascotas: $e');
    // No usar mascotas de fallback, simplemente mostrar mensaje de error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al cargar mascotas: $e'),
        duration: Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Reintentar',
          onPressed: () {
            _loadPetsData();
          },
        ),
      )
    );
  }
}

// Método para cargar solo datos del usuario desde la API
Future<void> _loadUserData() async {
  setState(() {
    isLoading = true;
  });
  
  try {
    // Intentamos cargar los datos del usuario
    await _getUserById();
    
    setState(() {
      isLoading = false;
    });
  } catch (e) {
    print('Error general al cargar datos de usuario: $e');
    setState(() {
      isLoading = false;
    });
    
    // Mostrar mensaje de error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al cargar datos del usuario: $e'),
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
    _speciesController.text = pet.species;
    _sexController.text = pet.sex;
    _bioController.text = pet.petBio;
    
    // Convertir imágenes en lista
    petImages = [];
    if (pet.petImage1.isNotEmpty) {
      petImages.add(pet.petImage1);
    }
    if (pet.petImage2 != null && pet.petImage2!.isNotEmpty) {
      petImages.add(pet.petImage2!);
    }
    if (pet.petImage3 != null && pet.petImage3!.isNotEmpty) {
      petImages.add(pet.petImage3!);
    }
  }
  
  void _saveCurrentPetData() {
    if (pets.isEmpty) return;
    
    // Como petBio es final, necesitamos crear una nueva instancia de PetModel con los datos actualizados
    PetModel currentPet = pets[selectedPetIndex];
    PetModel updatedPet = PetModel(
      id: currentPet.id,
      petUID: currentPet.petUID,
      ownerUID: currentPet.ownerUID,
      name: currentPet.name,
      petImage1: currentPet.petImage1,
      petImage2: currentPet.petImage2,
      petImage3: currentPet.petImage3,
      sex: currentPet.sex,
      petBio: _bioController.text, // Usar el valor actualizado del controlador
      birthDate: currentPet.birthDate,
      species: currentPet.species,
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
    // Esta función ahora mostraría un mensaje indicando que la funcionalidad
    // no está disponible en esta versión
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('La creación de nuevas mascotas no está disponible en esta versión.'),
        duration: Duration(seconds: 3),
      ),
    );
  }
  
  void _deleteCurrentPet() {
    // Esta función ahora mostraría un mensaje indicando que la funcionalidad
    // no está disponible en esta versión
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('La eliminación de mascotas no está disponible en esta versión.'),
        duration: Duration(seconds: 3),
      ),
    );
  }
  
  // Método para actualizar foto de usuario
  void _updateUserPhoto() async {
    // Seleccionar imagen de la galería
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      // Aquí implementarías la lógica para subir la imagen al servidor
      // Por ahora, simplemente simularemos que se actualizó correctamente
      
      setState(() {
        // Simulamos que la URL de la imagen se actualizó
        userImage = 'file://${image.path}';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Foto de perfil actualizada (simulación)'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
  
  // Método para establecer una foto de mascota como principal
  void _setPetMainPhoto(int index) {
    if (pets.isEmpty || index == 0) return; // Ya es la principal o no hay mascotas
    
    setState(() {
      PetModel currentPet = pets[selectedPetIndex];
      
      // Guarda la foto seleccionada
      String selectedPhoto = petImages[index];
      
      // Crear nueva lista de imágenes con la seleccionada como principal
      List<String> newPetImages = [selectedPhoto];
      
      // Añadir el resto de imágenes, excepto la seleccionada
      for (int i = 0; i < petImages.length; i++) {
        if (i != index) {
          newPetImages.add(petImages[i]);
        }
      }
      
      // Actualizar el modelo de la mascota
      PetModel updatedPet = PetModel(
        id: currentPet.id,
        petUID: currentPet.petUID,
        ownerUID: currentPet.ownerUID,
        name: currentPet.name,
        petImage1: newPetImages.length > 0 ? newPetImages[0] : '',
        petImage2: newPetImages.length > 1 ? newPetImages[1] : null,
        petImage3: newPetImages.length > 2 ? newPetImages[2] : null,
        sex: currentPet.sex,
        petBio: currentPet.petBio,
        birthDate: currentPet.birthDate,
        species: currentPet.species,
      );
      
      // Actualizar la mascota en la lista
      pets[selectedPetIndex] = updatedPet;
      
      // Actualizar la lista de imágenes para la UI
      petImages = newPetImages;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Foto establecida como principal'),
        duration: Duration(seconds: 3),
      ),
    );
  }
  
  // Método para eliminar una foto de mascota
  void _deletePetPhoto(int index) {
    if (pets.isEmpty || petImages.isEmpty) return;
    
    setState(() {
      PetModel currentPet = pets[selectedPetIndex];
      
      // Eliminar la foto seleccionada
      petImages.removeAt(index);
      
      // Actualizar el modelo de la mascota
      PetModel updatedPet = PetModel(
        id: currentPet.id,
        petUID: currentPet.petUID,
        ownerUID: currentPet.ownerUID,
        name: currentPet.name,
        petImage1: petImages.length > 0 ? petImages[0] : '',
        petImage2: petImages.length > 1 ? petImages[1] : null,
        petImage3: petImages.length > 2 ? petImages[2] : null,
        sex: currentPet.sex,
        petBio: currentPet.petBio,
        birthDate: currentPet.birthDate,
        species: currentPet.species,
      );
      
      // Actualizar la mascota en la lista
      pets[selectedPetIndex] = updatedPet;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Foto eliminada'),
        duration: Duration(seconds: 3),
      ),
    );
  }
  
  // Método para actualizar la foto de la mascota seleccionada
  Future<void> _updatePetPhoto(int photoIndex) async {
    if (pets.isEmpty) return;
    
    try {
      // Seleccionar imagen de la galería
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        // Aquí implementarías la lógica para subir la imagen al servidor
        // Por ahora, simplemente simularemos que se actualizó correctamente
        
        setState(() {
          // Actualizar la imagen en la lista de imágenes
          if (photoIndex < petImages.length) {
            petImages[photoIndex] = 'file://${image.path}';
          }
          
          PetModel currentPet = pets[selectedPetIndex];
          
          // Crear una nueva instancia de PetModel con las imágenes actualizadas
          PetModel updatedPet = PetModel(
            id: currentPet.id,
            petUID: currentPet.petUID,
            ownerUID: currentPet.ownerUID,
            name: currentPet.name,
            petImage1: petImages.length > 0 ? petImages[0] : '',
            petImage2: petImages.length > 1 ? petImages[1] : null,
            petImage3: petImages.length > 2 ? petImages[2] : null,
            sex: currentPet.sex,
            petBio: currentPet.petBio,
            birthDate: currentPet.birthDate,
            species: currentPet.species,
          );
          
          // Actualizar la mascota en la lista
          pets[selectedPetIndex] = updatedPet;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Foto de mascota actualizada'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error al actualizar foto: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar la foto: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
  
  // Método para añadir una nueva foto a la mascota
  Future<void> _addNewPetPhoto() async {
    if (pets.isEmpty) return;
    
    try {
      // Si ya tenemos 3 fotos, mostramos un mensaje
      if (petImages.length >= 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ya tienes el máximo de 3 fotos. Actualiza una existente.'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
      
      // Seleccionar imagen de la galería
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        setState(() {
          // Añadir nueva imagen a la lista
          petImages.add('file://${image.path}');
          
          PetModel currentPet = pets[selectedPetIndex];
          
          // Crear una nueva instancia de PetModel con las imágenes actualizadas
          PetModel updatedPet = PetModel(
            id: currentPet.id,
            petUID: currentPet.petUID,
            ownerUID: currentPet.ownerUID,
            name: currentPet.name,
            petImage1: petImages.length > 0 ? petImages[0] : '',
            petImage2: petImages.length > 1 ? petImages[1] : null,
            petImage3: petImages.length > 2 ? petImages[2] : null,
            sex: currentPet.sex,
            petBio: currentPet.petBio,
            birthDate: currentPet.birthDate,
            species: currentPet.species,
          );
          
          // Actualizar la mascota en la lista
          pets[selectedPetIndex] = updatedPet;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nueva foto añadida'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error al añadir nueva foto: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al añadir nueva foto: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
  
  // Método para guardar datos del usuario
  Future<void> _saveAllData() async {
  if (isSaving) return; // Evitar múltiples guardados simultáneos
  
  setState(() {
    isSaving = true;
  });
  
  try {
    // Guardar la biografía de la mascota actual antes de enviar
    if (pets.isNotEmpty) {
      _saveCurrentPetData();
    }
    
    // Guardar datos del usuario - solo la biografía es editable
    await _apiService.post(
      path: '/users/update',
      data: {
        'userUID': userId,
        'userBio': _userBioController.text,
      },
    );
    
    // Guardar datos de la mascota actual - biografía e imágenes
    if (pets.isNotEmpty) {
      PetModel currentPet = pets[selectedPetIndex];
      
      // Aquí deberíamos implementar la lógica para subir las imágenes al servidor
      // y luego actualizar las URLs en la base de datos
      
      await _apiService.post(
        path: '/pets/update',
        data: {
          'petUID': currentPet.petUID,
          'petBio': currentPet.petBio,
          'petImage1': currentPet.petImage1,
          'petImage2': currentPet.petImage2,
          'petImage3': currentPet.petImage3,
        },
      );
    }
    
    // Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Datos actualizados correctamente')),
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
  
  // Widget para mostrar campos no editables
  Widget _showNonEditableField(String label, String value, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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
                          backgroundImage: userImage.startsWith('file://')
                              ? FileImage(File(userImage.replaceFirst('file://', '')))
                              : NetworkImage(userImage) as ImageProvider,
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
                        '¡No tienes mascotas registradas!',
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
                      'Mis Mascotas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Ajuste de tamaño para la lista de mascotas
                SizedBox(
                  height: 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: List.generate(
                      pets.length + 1, // +1 para el botón de añadir
                      (index) {
                        if (index < pets.length) {
                          // Avatares de mascotas existentes
                          return GestureDetector(
                            onTap: () => _changePet(index),
                            child: Container(
                              margin: EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selectedPetIndex == index
                                      ? Colors.pink
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundImage: pets[index].petImage1.startsWith('file://')
                                    ? FileImage(File(pets[index].petImage1.replaceFirst('file://', '')))
                                    : NetworkImage(pets[index].petImage1) as ImageProvider,                                
                              ),
                            ),
                          );
                        } else {
                          // Botón para añadir nueva mascota
                          return GestureDetector(
                            onTap: _addNewPet,
                            child: Container(
                              margin: EdgeInsets.only(right: 16),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey.shade200,
                                child: Icon(
                                  Icons.add,
                                  size: 30,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),

                

                // Detalles de la mascota seleccionada
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Información de ${pets[selectedPetIndex].name}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.grey),
                      onPressed: _deleteCurrentPet,
                      tooltip: 'Eliminar mascota',
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // Selector de fotos de la mascota
                SelectorFotos(
                  imagenes: petImages,
                  onSetMainPhoto: _setPetMainPhoto,
                  onDeletePhoto: _deletePetPhoto,
                  onAddNewPhoto: _addNewPetPhoto,
                  maxPhotos: 3,
                  onReplacePhoto: _updatePetPhoto,
                ),

                // Datos básicos no editables
                Row(
                  children: [
                    // Columna izquierda - datos básicos
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _showNonEditableField('Nombre', _nameController.text, Icons.pets),
                          _showNonEditableField('Especie', _speciesController.text, Icons.category),
                          _showNonEditableField('Sexo', _sexController.text, Icons.male),
                          _showNonEditableField('Edad', _ageController.text, Icons.cake),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Biografía de la mascota - editable
                EditCampoTexto(
                  label: 'Biografía de la mascota',
                  controller: _bioController,
                  icon: Icons.description,
                  maxLines: 4,
                ),
                SizedBox(height: 24),                
              ],
            ],
          ),
        ),
    );
  }
  
  @override
  void dispose() {
    // Liberar recursos
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