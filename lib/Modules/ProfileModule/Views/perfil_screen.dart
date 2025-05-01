// Importaciones necesarias - añadidas para solucionar errores
import 'package:flutter/material.dart';
import 'dart:io'; // Para FileImage
import 'package:dio/dio.dart'; // Para FormData y MultipartFile
import 'package:provider/provider.dart';
import '../../../Resources/Widgets/edit_campo_texto.dart';
import '../../../Resources/Widgets/selector_fotos.dart';
import 'package:mascotas_citas/models/PetModel.dart';
import 'package:mascotas_citas/services/ApiService.dart';
import 'ajustes_screen.dart';
import 'package:mascotas_citas/services/auth/AuthSesionDataService.dart';
import 'package:mascotas_citas/services/platform/storage/SecureStorage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mascotas_citas/Resources/providers/theme_provider.dart';


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
  
// Método actualizado para cargar datos de la mascota actual
void _loadPetData(int index) {
  if (pets.isEmpty) return;
  
  PetModel pet = pets[index];
  _nameController.text = pet.name;
  _ageController.text = "${DateTime.now().difference(pet.birthDate).inDays ~/ 365}";
  _speciesController.text = pet.species;
  _sexController.text = pet.sex;
  _bioController.text = pet.petBio;
  
  // Convertir imágenes en lista, asegurándose de no agregar imágenes vacías
  List<String> newPetImages = [];
  if (pet.petImage1.isNotEmpty) {
    newPetImages.add(pet.petImage1);
  }
  if (pet.petImage2 != null && pet.petImage2!.isNotEmpty) {
    newPetImages.add(pet.petImage2!);
  }
  if (pet.petImage3 != null && pet.petImage3!.isNotEmpty) {
    newPetImages.add(pet.petImage3!);
  }
  
  // Actualizar la lista de imágenes
  setState(() {
    petImages = newPetImages;
  });
  
  print("Datos de mascota cargados. Imágenes: $petImages");
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

// Método para manejar la actualización de la imagen de perfil del usuario
void _onUserImageUpdated(List<String> updatedImages) {
  if (updatedImages.isEmpty) return;
  
  setState(() {
    userImage = updatedImages.first;
  });
  
  // Mostrar mensaje de éxito
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Foto de perfil actualizada correctamente'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    ),
  );
}

// Método actualizado para usar el orquestador al actualizar la foto de usuario
Future<void> _updateUserPhoto() async {
  try {
    // Mostrar indicador de carga
    setState(() {
      isLoading = true;
    });
    
    // Seleccionar imagen de la galería
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Reducir calidad para optimizar tamaño
    );
    
    if (image != null) {
      // Crear un objeto File desde el XFile
      File imageFile = File(image.path);
      
      // Preparar los datos para enviar al orquestador
      final formData = FormData.fromMap({
        'userImage': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'user_image.jpg',
        ),
      });
      
      // Realizar la solicitud al nuevo endpoint del orquestador
      final response = await _apiService.post(
        path: 'http://localhost:8093/api/update-user-image',
        data: formData,
      );
      
      // Asegurar que se envíe el userUID en los headers
      // Asumiendo que _apiService tiene una propiedad dio para acceder al cliente Dio
      // Si no existe, necesitarás modificar la clase ApiService para exponer esta propiedad
      
      if (_apiService is ApiService) {
      _apiService.dioClient.options.headers['userUID'] = userId;
      
    }
      
      if (response.statusCode == 200) {
        // Si la respuesta incluye la URL actualizada de la imagen
        if (response.data != null && response.data['userImage1'] != null) {
          setState(() {
            userImage = response.data['userImage1'];
          });
        } else {
          // Si no hay URL en la respuesta, usar la ruta local temporalmente
          setState(() {
            userImage = 'file://${image.path}';
          });
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Foto de perfil actualizada correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        throw Exception('Error al actualizar foto: ${response.statusCode}');
      }
    }
  } catch (e) {
    // Manejar errores
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ),
    );
    print('Error al actualizar foto: $e');
  } finally {
    // Ocultar indicador de carga
    setState(() {
      isLoading = false;
    });
  }
}
  
// Callback actualizado para actualizar las imágenes desde el selector de fotos
// usando el orquestador
void _onPetImagesUpdated(List<String> updatedImages) async {
  if (pets.isEmpty) return;
  
  print("Imágenes actualizadas recibidas del selector: $updatedImages");
  
  // Primero asegurarse de que la lista local se actualice
  setState(() {
    petImages = List.from(updatedImages); // Crear una nueva lista para evitar referencia compartida
  });
  
  try {
    // Obtener la mascota actual
    PetModel currentPet = pets[selectedPetIndex];
    
    // Preparar los archivos para enviar
    List<File> imageFiles = [];
    
    // Convertir las URLs a archivos si son locales (empiezan con 'file://')
    for (String imagePath in updatedImages) {
      if (imagePath.startsWith('file://')) {
        imageFiles.add(File(imagePath.replaceFirst('file://', '')));
      }
    }
    
    // Si no hay archivos nuevos para actualizar, no hacemos nada
    if (imageFiles.isEmpty) {
      print("No hay nuevas imágenes para subir");
      return;
    }
    
    // Preparar el FormData para el orquestador
    FormData formData = FormData();
    
    // Agregar las imágenes al FormData
    for (int i = 0; i < imageFiles.length; i++) {
      formData.files.add(
        MapEntry(
          'petImage${i + 1}',
          await MultipartFile.fromFile(
            imageFiles[i].path,
            filename: 'pet_image_${i + 1}.jpg',
          ),
        ),
      );
    }
    
    // Establecer los headers necesarios
    // Asumiendo que _apiService tiene una propiedad dio para acceder al cliente Dio
    if (_apiService is ApiService) {
      _apiService.dioClient.options.headers['userUID'] = userId;
      _apiService.dioClient.options.headers['petUID'] = currentPet.petUID;
    }
    
    // Realizar la solicitud al endpoint del orquestador
    final response = await _apiService.post(
      path: 'http://localhost:8093/api/update-pet-images',
      data: formData,
    );
    
    if (response.statusCode == 200) {
      // Actualizar el modelo de la mascota con las nuevas URLs si se devuelven
      if (response.data != null) {
        PetModel updatedPet = PetModel(
          id: currentPet.id,
          petUID: currentPet.petUID,
          ownerUID: currentPet.ownerUID,
          name: currentPet.name,
          petImage1: response.data['petImage1'] ?? currentPet.petImage1,
          petImage2: response.data['petImage2'] ?? currentPet.petImage2,
          petImage3: response.data['petImage3'] ?? currentPet.petImage3,
          sex: currentPet.sex,
          petBio: currentPet.petBio,
          birthDate: currentPet.birthDate,
          species: currentPet.species,
        );
        
        // Actualizar la mascota en la lista
        setState(() {
          pets[selectedPetIndex] = updatedPet;
        });
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Imágenes de ${currentPet.name} actualizadas correctamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      throw Exception('Error al actualizar imágenes: ${response.statusCode}');
    }
    
  } catch (e) {
    print('Error al actualizar imágenes de mascota: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al actualizar imágenes: $e'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }
}

// Método para guardar específicamente las imágenes de una mascota en el servidor
// usando el orquestador
Future<void> _saveSpecificPetImages(PetModel pet, List<File> imageFiles) async {
  try {
    // Preparar el FormData para el orquestador
    FormData formData = FormData();
    
    // Agregar las imágenes al FormData
    for (int i = 0; i < imageFiles.length && i < 3; i++) {
      formData.files.add(
        MapEntry(
          'petImage${i + 1}',
          await MultipartFile.fromFile(
            imageFiles[i].path,
            filename: 'pet_image_${i + 1}.jpg',
          ),
        ),
      );
    }
    
    // Establecer los headers necesarios
    // Asumiendo que _apiService tiene una propiedad dio para acceder al cliente Dio
    if (_apiService is ApiService) {
      _apiService.dioClient.options.headers['userUID'] = userId;
      _apiService.dioClient.options.headers['petUID'] = pet.petUID;
    }
    
    // Realizar la solicitud al endpoint del orquestador
    final response = await _apiService.post(
      path: 'http://localhost:8093/api/update-pet-images',
      data: formData,
    );
    
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar imágenes: ${response.statusCode}');
    }
    
    print("Imágenes guardadas en el servidor con éxito");
    return;
    
  } catch (e) {
    print('Error al guardar imágenes en el servidor: $e');
    throw e;
  }
}
  
// Método para guardar solo las biografías (usuario y mascota)
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
    
    // --- ACTUALIZAR SOLO LA BIOGRAFÍA DEL USUARIO ---
    Map<String, dynamic> userData = {
      'userUID': userId,
      'userBio': _userBioController.text,
    };
    
    // Realizar la solicitud de actualización de la biografía del usuario
    final userResponse = await _apiService.post(
      path: 'http://localhost:8082/users/update',
      data: userData,
    );
    
    // Verificar si la actualización del usuario fue exitosa
    if (userResponse.statusCode != 200) {
      throw Exception('Error al actualizar la biografía del usuario: ${userResponse.statusCode}');
    }
    
    // --- ACTUALIZAR SOLO LA BIOGRAFÍA DE LA MASCOTA (si existe) ---
    if (pets.isNotEmpty) {
      PetModel currentPet = pets[selectedPetIndex];
      
      // Crear el objeto de datos de la mascota (solo biografía)
      Map<String, dynamic> petData = {
        'petUID': currentPet.petUID,
        'petBio': currentPet.petBio,
      };
      
      // Realizar la solicitud de actualización de la biografía de la mascota
      final petResponse = await _apiService.post(
        path: 'http://localhost:8083/pets/update',
        data: petData,
      );
      
      // Verificar si la actualización de la mascota fue exitosa
      if (petResponse.statusCode != 200) {
        throw Exception('Error al actualizar la biografía de la mascota: ${petResponse.statusCode}');
      }
    }
    
    // Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Biografías actualizadas correctamente'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    
  } catch (e) {
    print('Error al guardar datos: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al guardar datos: $e'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
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
    // Obtiene el tema actual y la referencia al ThemeProvider personalizado
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    // Usar el tema adecuado según el modo
    final theme = isDarkMode ? themeProvider.darkTheme : themeProvider.lightTheme;
    
    // Determinar si hay mascotas registradas
    final bool hasPets = pets.isNotEmpty;
    
    return Theme(
      // Aplicar el tema personalizado a este widget y sus hijos
      data: theme,
      child: Scaffold(      
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
                      color: theme.colorScheme.primary,
                      strokeWidth: 2.0,
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _saveAllData,
                  child: Text('Guardar', style: TextStyle(color: theme.colorScheme.primary)),
                ),
          ],
        ),
        body: isLoading 
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
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
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.more_vert, color: theme.colorScheme.primary),
                      onPressed: _showSettings,
                      tooltip: 'Ajustes',
                    ),
                  ],
                ),
                SizedBox(height: 16),
                
                // Tarjeta para foto del usuario y datos básicos
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Foto del usuario usando SelectorFotos
                      Container(
                        width: 100,
                        height: 100,
                        child: SelectorFotos(
                          imagenes: [userImage], // Usuario tiene una sola imagen de perfil
                          onImagesUpdated: _onUserImageUpdated,
                          maxPhotos: 1, // Solo permitir una foto para el perfil
                          entidadId: userId, // Usar el ID del usuario
                          userUID: userId,
                          tipo: 'usuario', // Especificar que es para un usuario
                          apiService: _apiService,
                        ),
                      ),
                      SizedBox(width: 16),
                      // Datos del usuario (solo Bio es editable)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título
                            Row(
                              children: [
                                Icon(Icons.person, size: 16, color: theme.colorScheme.primary),
                                SizedBox(width: 6),
                                Text(
                                  "Nombre:",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _userNameController.text,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            Divider(height: 16, thickness: 0.5),
                            
                            // Datos en filas
                            Row(
                              children: [
                                // Columna izquierda
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.person_outline, size: 14, color: theme.colorScheme.outline),
                                          SizedBox(width: 4),
                                          Text(
                                            "Sexo:",
                                            style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        _userSexController.text,
                                        style: TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                                // Columna derecha
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.cake, size: 14, color: theme.colorScheme.outline),
                                          SizedBox(width: 4),
                                          Text(
                                            "Edad:",
                                            style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        "${_userAgeController.text} años",
                                        style: TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 10),
                            
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 14, color: theme.colorScheme.outline),
                                SizedBox(width: 4),
                                Text(
                                  "Ubicación:",
                                  style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  _userLocationController.text,
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Biografía en tarjeta separada
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.description, size: 16, color: theme.colorScheme.primary),
                          SizedBox(width: 8),
                          Text(
                            "Biografía",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _userBioController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Cuéntanos sobre ti...",
                          hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                          fillColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
                          filled: true,
                          contentPadding: EdgeInsets.all(12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: theme.colorScheme.primaryContainer),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: theme.colorScheme.primaryContainer),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: theme.colorScheme.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 32),
    
                // Mensaje para usuarios sin mascota
                if (!hasPets)
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.colorScheme.primaryContainer),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.pets, size: 40, color: theme.colorScheme.primary),
                        SizedBox(height: 10),
                        Text(
                          '¡No tienes mascotas registradas!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'La creación de mascotas estará disponible próximamente.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _addNewPet,
                          icon: Icon(Icons.add),
                          label: Text('Añadir Mascota'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
    
                // Sección de mascotas (solo visible si hay mascotas)
    if (hasPets) ...[
      // Encabezado de sección
      Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: theme.colorScheme.primaryContainer, width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mis Mascotas',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            IconButton(
              onPressed: () => _deleteCurrentPet(),
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              tooltip: 'Eliminar Mascota',
            ),
          ],
        ),
      ),
      SizedBox(height: 20),
      
      // Carrusel de selección de mascotas con botón de añadir
      Container(
        height: 100,
        child: Row(
          children: [
            // Lista de mascotas
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: pets.length,
                itemBuilder: (context, index) {
                  PetModel pet = pets[index];
                  bool isSelected = index == selectedPetIndex;
                  
                  return GestureDetector(
                    onTap: () => _changePet(index),
                    child: Container(
                      width: 85,
                      margin: EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                        color: isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Foto de la mascota con indicador de selección
                          Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: theme.colorScheme.surfaceVariant,
                              backgroundImage: pet.petImage1.isNotEmpty 
                                ? (pet.petImage1.startsWith('file://') 
                                    ? FileImage(File(pet.petImage1.replaceFirst('file://', ''))) 
                                    : NetworkImage(pet.petImage1)) as ImageProvider
                                : AssetImage('assets/images/placeholder_pet.png') as ImageProvider,
                            ),
                          ),
                          SizedBox(height: 8),
                          // Nombre de la mascota
                          Text(
                            pet.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onBackground,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Botón circular de añadir mascota
            Container(
              width: 70,
              child: GestureDetector(
                onTap: () => _addNewPet(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary,
                      ),
                      child: Icon(
                        Icons.add,
                        color: theme.colorScheme.onPrimary,
                        size: 30,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Añadir',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 25),
      
      // Panel de detalles de la mascota seleccionada
      if (selectedPetIndex < pets.length && pets.isNotEmpty)
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.primaryContainer, width: 1),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector de fotos (MOVIDO ARRIBA)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.primaryContainer, width: 1),
                ),
                child: SelectorFotos(
                  imagenes: petImages,
                  onImagesUpdated: _onPetImagesUpdated,
                  maxPhotos: 3,
                  entidadId: pets[selectedPetIndex].id,
                  userUID: userId,
                  tipo: 'mascota',
                  apiService: _apiService,
                ),
              ),
              SizedBox(height: 16),
              
              // Información básica
              // Datos de la mascota
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Row(
                      children: [
                        Icon(Icons.pets, size: 16, color: theme.colorScheme.primary),
                        SizedBox(width: 6),
                        Text(
                          "Nombre:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _nameController.text,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    Divider(height: 16, thickness: 0.5),
                    
                    // Datos en filas
                    Row(
                      children: [
                        // Columna izquierda
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.category, size: 14, color: theme.colorScheme.outline),
                                  SizedBox(width: 4),
                                  Text(
                                    "Especie:",
                                    style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2),
                              Text(
                                _speciesController.text,
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        // Columna derecha
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.transgender, size: 14, color: theme.colorScheme.outline),
                                  SizedBox(width: 4),
                                  Text(
                                    "Sexo:",
                                    style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2),
                              Text(
                                _sexController.text,
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 10),
                    
                    Row(
                      children: [
                        Icon(Icons.cake, size: 14, color: theme.colorScheme.outline),
                        SizedBox(width: 4),
                        Text(
                          "Edad:",
                          style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
                        ),
                        SizedBox(width: 4),
                        Text(
                          "${_ageController.text} años",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 16),
              
              // Biografía en tarjeta separada
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.description, size: 16, color: theme.colorScheme.primary),
                        SizedBox(width: 8),
                        Text(
                          "Biografía",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _bioController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Describe a tu mascota aquí...",
                        hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                        fillColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
                        filled: true,
                        contentPadding: EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: theme.colorScheme.primaryContainer),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: theme.colorScheme.primaryContainer),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: theme.colorScheme.primary),
                        ),
                      ),
                      onChanged: (text) {
                        if (pets.isNotEmpty) {
                          setState(() {
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
                              petBio: text,
                              birthDate: currentPet.birthDate,
                              species: currentPet.species,
                            );
                            pets[selectedPetIndex] = updatedPet;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    ],
          ],
        ),
      ),
      ),
    );
}

@override
void dispose() {
  // Liberar controladores al destruir el widget
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