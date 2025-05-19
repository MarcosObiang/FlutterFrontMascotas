import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mascotas_citas/models/PetModel.dart';
import 'package:mascotas_citas/services/ApiService.dart';
import 'package:mascotas_citas/services/auth/AuthSesionDataService.dart';

/// ViewModel para la pantalla de perfil
/// 
/// Esta clase maneja toda la lógica relacionada con el perfil del usuario
/// y sus mascotas, separando la lógica de negocio de la presentación visual.
class PerfilViewModel extends ChangeNotifier {
  // Identificador del usuario
  late String userId;
  
  
  // Servicios
  final ApiService _apiService;
  final AuthDataService _authDataService;
  
  // Datos del usuario
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userAgeController = TextEditingController();
  final TextEditingController userSexController = TextEditingController();
  final TextEditingController userLocationController = TextEditingController();
  final TextEditingController userBioController = TextEditingController();
  String userImage = 'https://via.placeholder.com/150'; // URL de imagen por defecto
  
  // NUEVO: Fecha de nacimiento del usuario como String formateado
  String? _userBirthDateStr;
  // NUEVO: Fecha de nacimiento del usuario como objeto DateTime
  DateTime? _userBirthDate;
  
  // Lista de mascotas
  List<PetModel> pets = [];
  
  // Índice de la mascota seleccionada y estados
  int selectedPetIndex = 0;
  bool isLoading = true;
  bool isSaving = false;
  
  // NUEVO: Estado específico para la carga inicial
  bool _isInitialLoading = true;
  
  // Controladores para la mascota actual
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController speciesController = TextEditingController();
  final TextEditingController sexController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  List<String> petImages = [];
  
  // ImagePicker
  final ImagePicker _picker = ImagePicker();
  
  // Constructor
  PerfilViewModel({
    required ApiService apiService,
    required AuthDataService authDataService,
  }) : _apiService = apiService,
       _authDataService = authDataService {
    _init();
  }
  
  /// Getter para acceder al servicio API desde fuera de esta clase
  ApiService get apiService => _apiService;
  
  /// NUEVO: Getter para el estado de carga inicial
  bool get isInitialLoading => _isInitialLoading;
  
  /// NUEVO: Getter para acceder a la fecha de nacimiento del usuario como DateTime
  DateTime? get userBirthDate => _userBirthDate;
  
  /// NUEVO: Getter para acceder a la fecha de nacimiento del usuario como String formateado
  String get userBirthDateStr => _userBirthDateStr ?? '';
  
  /// Getter para obtener la mascota actual basada en el selectedPetIndex
  PetModel? get currentPet => 
    pets.isNotEmpty && selectedPetIndex >= 0 && selectedPetIndex < pets.length 
      ? pets[selectedPetIndex] 
      : null;
  
  
  /// Construye la URL completa para visualizar una imagen desde el servicio de media
  String buildMediaUrl(String imageName) {
    const String mediaBaseUrl = 'http://localhost:8091/media/get-media';
    
    if (imageName.isEmpty) {
      return 'https://via.placeholder.com/150';
    }
    
    if (imageName.startsWith('http://') || imageName.startsWith('https://')) {
      return imageName;
    }
    
    return '$mediaBaseUrl?fileName=$imageName';
  }

  /// Construye URL para imagen de usuario
  String buildUserImageUrl(dynamic userImage) {
    if (userImage == null || userImage.toString().isEmpty) {
      return 'https://via.placeholder.com/150';
    }
    
    String imageStr = userImage.toString();
    
    if (imageStr.startsWith('http://') || imageStr.startsWith('https://')) {
      return imageStr;
    }
    
    if (imageStr == 'profileImage' || imageStr.contains('placeholder')) {
      return 'https://via.placeholder.com/150';
    }
    
    return buildMediaUrl(imageStr);
  }

  /// Construye URL para imagen de mascota
  String buildPetImageUrl(dynamic petImage) {
    if (petImage == null || petImage.toString().isEmpty) {
      return 'https://via.placeholder.com/150/cccccc/FFFFFF/?text=Mascota';
    }
    
    String imageStr = petImage.toString();
    
    if (imageStr.startsWith('http://') || imageStr.startsWith('https://')) {
      return imageStr;
    }
    
    if (imageStr == 'profileImage' || imageStr.contains('placeholder')) {
      return 'https://via.placeholder.com/150/cccccc/FFFFFF/?text=Mascota';
    }
    
    return buildMediaUrl(imageStr);
  }
  
  /// Inicializa el ViewModel cargando los datos necesarios
  void _init() {
    // Cargar y mostrar datos almacenados
    _authDataService.loadStoredData().then((_) {
      // Obtenemos el userId después de cargar los datos
      userId = '915f1952df'; // ID que corresponde al usuario de prueba en localhost
      print('User ID para pruebas con localhost: "$userId"');
      
      // Obtener y mostrar todos los datos de autenticación para depuración
      String? token = _authDataService.getToken();
      String? refreshToken = _authDataService.getRefreshToken();
      DateTime? expDate = _authDataService.getExpirationDate();
      
      print('======= DATOS DE AUTENTICACIÓN =======');
      print('User ID: "$userId"');
      print('Token: "${token ?? "no hay token"}"');
      print('Refresh Token: "${refreshToken ?? "no hay refresh token"}"');
      print('Fecha Expiración: ${expDate?.toString() ?? "no hay fecha"}');
      print('=====================================');
      
      // NUEVO: Usar loadAllData en lugar de cargar datos por separado
      loadAllData();
    });
  }
  
  /// NUEVO: Método para cargar todos los datos (usuario y mascotas)
  Future<void> loadAllData() async {
    _isInitialLoading = true; // Indicar que se está realizando la carga inicial
    isLoading = true;
    notifyListeners();
    
    try {
      // Cargar datos de usuario
      await loadUserData();
      
      // Cargar datos de mascotas
      await loadPetsData();
      
      _isInitialLoading = false; // Marcar que la carga inicial ha finalizado
      isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error al cargar todos los datos: $e');
      _isInitialLoading = false;
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  
  /// Carga los datos del usuario desde la API
  Future<void> loadUserData() async {
    isLoading = true;
    notifyListeners();
    
    try {
      await _getUserById();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error general al cargar datos de usuario: $e');
      isLoading = false;
      notifyListeners();
      rethrow; // Propagar error para manejarlo en la UI
    }
  }
  
  /// Obtiene los datos del usuario por su ID
  Future<dynamic> _getUserById() async {
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
        userNameController.text = userData['name'] ?? '';
        
        // Calcular edad desde birthDate (en formato ISO)
        if (userData['birthDate'] != null) {
          try {
            // Guardar la fecha como string antes de parsearla (si viene como string)
            if (userData['birthDate'] is String) {
              _userBirthDateStr = userData['birthDate'].toString().split('T')[0];
              // Intentar parsear el formato ISO
              _userBirthDate = DateTime.parse(_userBirthDateStr!);
            } else {
              // Si es un timestamp o algún otro formato
              _userBirthDate = DateTime.fromMillisecondsSinceEpoch(
                  userData['birthDate'] is int 
                      ? userData['birthDate'] 
                      : int.parse(userData['birthDate'].toString())
              );
              // Formatear la fecha como string YYYY-MM-DD
              _userBirthDateStr = "${_userBirthDate!.year}-${_userBirthDate!.month.toString().padLeft(2, '0')}-${_userBirthDate!.day.toString().padLeft(2, '0')}";
            }
            
            final age = DateTime.now().difference(_userBirthDate!).inDays ~/ 365;
            userAgeController.text = age.toString();
          } catch (e) {
            userAgeController.text = "No disponible";
            print('Error al parsear fecha de nacimiento: $e');
          }
        } else {
          userAgeController.text = "No disponible";
        }
        
        userSexController.text = userData['sex'] ?? '';
        userLocationController.text = userData['location'] ?? 'No disponible';
        userBioController.text = userData['userBio'] ?? '';
        
        // Usar la nueva función para construir la URL de la imagen del usuario
        userImage = buildUserImageUrl(userData['userImage1']);
        
        notifyListeners();
        return userData;
      } else {
        throw Exception('Error al obtener el usuario: ${userResponse.statusCode}');
      }
    } catch (e) {
      print('Error al obtener el usuario: $e');
      rethrow;
    }
  }
  
  /// Carga los datos de las mascotas desde la API
  Future<void> loadPetsData() async {
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
          // Manejar diferentes formatos de fechas
          DateTime birthDate;
          try {
            if (petData['birthDate'] is String) {
              // Si birthDate es un string (formato ISO)
              birthDate = DateTime.parse(petData['birthDate'].toString().split('T')[0]);
            } else {
              // Si birthDate es un timestamp
              birthDate = DateTime.fromMillisecondsSinceEpoch(petData['birthDate'] ?? 0);
            }
          } catch (e) {
            print('Error al parsear fecha de nacimiento de mascota: $e');
            // Fecha por defecto si hay error
            birthDate = DateTime.now();
          }
          
          PetModel pet = PetModel(
            id: petData['id'] ?? '',
            petUID: petData['petUID'] ?? '',
            ownerUID: petData['ownerUID'] ?? '',
            name: petData['name'] ?? '',
            // Usar las nuevas funciones para construir URLs de imágenes de mascotas
            petImage1: buildPetImageUrl(petData['petImage1']),
            petImage2: buildPetImageUrl(petData['petImage2']),
            petImage3: buildPetImageUrl(petData['petImage3']),
            sex: petData['sex'] ?? '',
            petBio: petData['petBio'] ?? '',
            birthDate: birthDate,
            species: petData['species'] ?? '',
          );
          fetchedPets.add(pet);
        }
        
        pets = fetchedPets;
        
        if (pets.isNotEmpty) {
          loadPetData(0);
        }
        
        notifyListeners();
        print('Mascotas cargadas correctamente: ${pets.length}');
      } else {
        throw Exception('Error al obtener mascotas: ${petsResponse.statusCode}');
      }
    } catch (e) {
      print('Error al cargar mascotas: $e');
      rethrow; // Propagar error para manejarlo en la UI
    }
  }
  
  /// NUEVO: Método para cargar mascotas (alias de loadPetsData para compatibilidad)
  Future<void> loadPets() async {
    await loadPetsData();
  }
  
  /// Valida y proporciona URL de imagen segura (simplificada)
  String _validateImageUrl(dynamic imageUrl) {
    return buildPetImageUrl(imageUrl);
  }
  
  /// Carga los datos de una mascota específica
  void loadPetData(int index) {
    if (pets.isEmpty) return;
    
    selectedPetIndex = index;
    
    PetModel pet = pets[index];
    nameController.text = pet.name;
    ageController.text = "${DateTime.now().difference(pet.birthDate).inDays ~/ 365}";
    speciesController.text = pet.species;
    sexController.text = pet.sex;
    bioController.text = pet.petBio;
    
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
    
    // Si no hay imágenes válidas, agregar una imagen de placeholder
    if (newPetImages.isEmpty) {
      newPetImages.add('https://via.placeholder.com/150/cccccc/FFFFFF/?text=Mascota');
    }
    
    // Actualizar la lista de imágenes
    petImages = newPetImages;
    
    notifyListeners();
    print("Datos de mascota cargados. Imágenes: $petImages");
  }
  
  /// Guarda los datos de la mascota actual
  void saveCurrentPetData() {
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
      petBio: bioController.text, // Usar el valor actualizado del controlador
      birthDate: currentPet.birthDate,
      species: currentPet.species,
    );
    
    // Actualizar la mascota actual
    pets[selectedPetIndex] = updatedPet;
    notifyListeners();
  }
  
  /// Cambia a otra mascota
  void changePet(int index) {
    // Guardar datos de la mascota actual antes de cambiar
    saveCurrentPetData();
    loadPetData(index);
  }
  
  /// Añade una nueva mascota
Future<void> addNewPet({
  required String name,
  required String species,
  required String sex,
  required String birthDate,
  required String bio,
  required File petImage1,
  File? petImage2,
  File? petImage3,
}) async {
  try {
    // Indicar que estamos cargando
    isSaving = true;
    notifyListeners();
    
    // Crear FormData para manejar los archivos
    FormData formData = FormData();
    
    // Agregar las imágenes
    if (petImage1 != null) {
      formData.files.add(MapEntry(
        'petImage1',
        await MultipartFile.fromFile(
          petImage1.path,
          filename: 'pet_image_1.jpg',
        ),
      ));
    }
    
    if (petImage2 != null) {
      formData.files.add(MapEntry(
        'petImage2',
        await MultipartFile.fromFile(
          petImage2.path,
          filename: 'pet_image_2.jpg',
        ),
      ));
    }
    
    if (petImage3 != null) {
      formData.files.add(MapEntry(
        'petImage3',
        await MultipartFile.fromFile(
          petImage3.path,
          filename: 'pet_image_3.jpg',
        ),
      ));
    }
    
    // Crear JSON para los datos de la mascota
    Map<String, dynamic> petJson = {
      'name': name,
      'sex': sex,
      'location': {
        'type': 'Point',
        'coordinates': [-99.1269, 19.4978] // Coordenadas predeterminadas (Ciudad de México)
      },
      'petBio': bio,
      'birthDate': birthDate,
      'species': species
    };
    
    // Convertir el mapa a una cadena JSON
    String petJsonString = jsonEncode(petJson);
    
    // Agregar el JSON como parte del FormData
    formData.fields.add(MapEntry('petJson', petJsonString));
    
    // Establecer el encabezado userUID para autenticación
    _apiService.dioClient.options.headers['userUID'] = userId;
    
    // Enviar la solicitud POST
    final response = await _apiService.post(
      path: 'http://localhost:8093/api/pets/create', // URL del orquestador
      data: formData,
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Crear una nueva mascota con la respuesta
      final petData = response.data;
      
      // Procesar la fecha de nacimiento
      DateTime birthDateObj;
      try {
        birthDateObj = DateTime.parse(birthDate);
      } catch (e) {
        print('Error al parsear fecha de nacimiento: $e');
        birthDateObj = DateTime.now();
      }
      
      // Crear el nuevo modelo de mascota
      PetModel newPet = PetModel(
        id: petData['id'] ?? '',
        petUID: petData['petUID'] ?? '',
        ownerUID: userId,
        name: name,
        petImage1: buildPetImageUrl(petData['petImage1']),
        petImage2: petData['petImage2'] != null ? buildPetImageUrl(petData['petImage2']) : null,
        petImage3: petData['petImage3'] != null ? buildPetImageUrl(petData['petImage3']) : null,
        sex: sex,
        petBio: bio,
        birthDate: birthDateObj,
        species: species,
      );
      
      // Agregar la nueva mascota a la lista
      pets.add(newPet);
      
      // Seleccionar la nueva mascota
      selectedPetIndex = pets.length - 1;
      
      // Cargar los datos de la nueva mascota en los controladores
      loadPetData(selectedPetIndex);
      
      print('Mascota creada exitosamente: ${newPet.name}');
    } else {
      throw Exception('Error al crear mascota: ${response.statusCode}');
    }
  } catch (e) {
    print('Error al crear mascota: $e');
    throw Exception('No se pudo crear la mascota: $e');
  } finally {
    isSaving = false;
    notifyListeners();
  }
}
    
  
/// Elimina la mascota actual
Future<void> deleteCurrentPet() async {
  // Verificar si hay mascotas para eliminar
  if (pets.isEmpty) {
    throw Exception('No hay mascotas para eliminar');
  }
  
  // Obtener la mascota actual
  PetModel currentPet = pets[selectedPetIndex];
  
  try {
    isLoading = true;
    notifyListeners();
    
    // Verificar que tenemos un ID válido
    if (currentPet.petUID.isEmpty) {
      throw Exception('ID de mascota no válido');
    }
    
    // Establecer el userUID en los headers para autenticación
    _apiService.dioClient.options.headers['userUID'] = userId;
    
    // Construir la URL del endpoint según lo mostrado en Postman
    // {{base_url}}/pets/delete?petUID=dKqmCfBId8
    const String baseUrl = 'http://localhost:8083'; // El microservicio de mascotas
    final String path = '$baseUrl/pets/delete';
    
    // Realizar la solicitud POST al endpoint (según la captura muestra POST, no DELETE)
    final response = await _apiService.post(
      path: path,
      queryParams: {'petUID': currentPet.petUID},
    );
    
    if (response.statusCode == 200) {
      // Eliminar la mascota de la lista local
      pets.removeAt(selectedPetIndex);
      
      // Actualizar el índice seleccionado si es necesario
      if (pets.isEmpty) {
        selectedPetIndex = -1;
        // Limpiar los controladores ya que no hay mascota seleccionada
        nameController.clear();
        ageController.clear();
        speciesController.clear();
        sexController.clear();
        bioController.clear();
        petImages.clear();
      } else {
        // Si el índice era el último, seleccionar el nuevo último
        if (selectedPetIndex >= pets.length) {
          selectedPetIndex = pets.length - 1;
        }
        // Cargar los datos de la mascota ahora seleccionada
        loadPetData(selectedPetIndex);
      }
      
      print('Mascota eliminada correctamente');
    } else {
      throw Exception('Error al eliminar mascota: ${response.statusCode}');
    }
  } catch (e) {
    print('Error al eliminar mascota: $e');
    throw Exception('No se pudo eliminar la mascota: $e');
  } finally {
    isLoading = false;
    notifyListeners();
  }
}
  
  // Método para actualizar la biografía del usuario
Future<void> updateUserBio(String newBio) async {
  try {
    // Indicar que estamos guardando
    isSaving = true;
    notifyListeners();
    
    // Verificar que tenemos un ID válido
    if (userId.isEmpty) {
      throw Exception('ID de usuario no válido');
    }
    
    // Actualizar el controlador local
    userBioController.text = newBio;
    
    // Preparar los datos para la solicitud según el formato requerido
    Map<String, dynamic> userData = {
      'userUID': userId,
      'userBio': newBio,
    };
    
    // URL exacta del endpoint como se muestra en la imagen
    final String url = 'http://localhost:8082/users/update-bio';
    
    // Realizar la solicitud PUT como se muestra en Postman
    final response = await _apiService.put(
      path: url,
      data: {
        'userUID': userId,
        'userBio': newBio,
      },
    );
    
    if (response.statusCode == 200) {
      print('Biografía del usuario actualizada correctamente');
    } else {
      throw Exception('Error al actualizar la biografía del usuario: ${response.statusCode}');
    }
  } catch (e) {
    print('Error al actualizar la biografía del usuario: $e');
    throw Exception('No se pudo actualizar la biografía del usuario: $e');
  } finally {
    isSaving = false;
    notifyListeners();
  }
}


// Método para actualizar la biografía de la mascota actual
Future<void> updateCurrentPetBio(String newBio) async {
  try {
    // Verificar que hay mascotas para actualizar
    if (pets.isEmpty) {
      throw Exception('No hay mascotas para actualizar');
    }
    
    // Indicar que estamos guardando
    isSaving = true;
    notifyListeners();
    
    // Obtener la mascota actual
    PetModel currentPet = pets[selectedPetIndex];
    
    // Verificar que tenemos un ID válido
    if (currentPet.petUID.isEmpty) {
      throw Exception('ID de mascota no válido');
    }
    
    // Actualizar el controlador local
    bioController.text = newBio;
    
    // También actualizar el modelo de la mascota
    PetModel updatedPet = PetModel(
      id: currentPet.id,
      petUID: currentPet.petUID,
      ownerUID: currentPet.ownerUID,
      name: currentPet.name,
      petImage1: currentPet.petImage1,
      petImage2: currentPet.petImage2,
      petImage3: currentPet.petImage3,
      sex: currentPet.sex,
      petBio: newBio,
      birthDate: currentPet.birthDate,
      species: currentPet.species,
    );
    
    // Actualizar la mascota en la lista
    pets[selectedPetIndex] = updatedPet;
    
    // URL exacta del endpoint como se muestra en la imagen
    final String url = 'http://localhost:8083/pets/update-pet-bio';
    
    // Realizar la solicitud PUT como se muestra en Postman
    final response = await _apiService.put(
      path: url,
      data: {
        'petUID': currentPet.petUID,
        'petBio': newBio,
      },
    );
    
    if (response.statusCode == 200) {
      print('Biografía de la mascota actualizada correctamente');
    } else {
      throw Exception('Error al actualizar la biografía de la mascota: ${response.statusCode}');
    }
  } catch (e) {
    print('Error al actualizar la biografía de la mascota: $e');
    throw Exception('No se pudo actualizar la biografía de la mascota: $e');
  } finally {
    isSaving = false;
    notifyListeners();
  }
}


  /// Actualiza la imagen del usuario
Future<void> updateUserPhoto() async {
  try {
    isLoading = true;
    notifyListeners();
    
    // Seleccionar imagen de la galería
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    
    if (image != null) {
      // Crear un objeto File desde el XFile
      File imageFile = File(image.path);
      
      // Usar el método especializado con los parámetros correctos
      final response = await _apiService.updateUserImage(
        userUID: userId,
        userImage: imageFile,
      );
      
      if (response.statusCode == 200 && response.data != null) {
        // Según el MediaService, la respuesta es directamente el nombre del archivo
        // No es un JSON con 'profileImageUrl' o 'fileName'
        String fileName = '';
        
        // Verificar el tipo de respuesta y adaptarse adecuadamente
        if (response.data is String) {
          // Si la respuesta es directamente el nombre del archivo como string
          fileName = response.data;
        } else if (response.data is Map) {
          // Si es un mapa (JSON), intentar extraer el nombre del archivo
          fileName = response.data['fileName'] ?? response.data.toString();
        }
        
        // Actualizar la URL de la imagen en el ViewModel
        if (fileName.isNotEmpty) {
          userImage = buildMediaUrl(fileName);
          
          // También sería bueno actualizar esto en el modelo de usuario o donde corresponda
          // para que persista entre sesiones
          
          print('Imagen actualizada correctamente. Nueva URL: $userImage');
        } else {
          print('Nombre de archivo vacío en la respuesta');
          throw Exception('Respuesta inválida del servidor');
        }
        
        notifyListeners();
      } else {
        throw Exception('Error al actualizar imagen: ${response.statusCode}');
      }
    }
  } catch (e) {
    print('Error al actualizar foto de perfil: $e');
    rethrow;
  } finally {
    isLoading = false;
    notifyListeners();
  }
}
  
  /// Actualiza las imágenes de una mascota
  Future<void> updatePetImages(List<String> updatedImages) async {
    if (pets.isEmpty) return;
    
    print("Imágenes actualizadas recibidas del selector: $updatedImages");
    
    // Primero asegurarse de que la lista local se actualice
    petImages = List.from(updatedImages); // Crear una nueva lista para evitar referencia compartida
    notifyListeners();
    
    try {
      // Obtener la mascota actual
      PetModel currentPet = pets[selectedPetIndex];
      
      // Preparar los archivos para enviar
      List<File> imageFiles = [];
      
      // Convertir las URLs a archivos si son locales (empiezan con 'file://')
      for (String imagePath in updatedImages) {
        if (imagePath.startsWith('file://')) {
          String cleanPath = imagePath.replaceFirst('file://', '');
          File file = File(cleanPath);
          if (await file.exists()) {
            imageFiles.add(file);
          } else {
            print("Archivo no encontrado: $cleanPath");
          }
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
      _apiService.dioClient.options.headers['userUID'] = userId;
      _apiService.dioClient.options.headers['petUID'] = currentPet.petUID;
          
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
            petImage1: buildPetImageUrl(response.data['petImage1']) ?? currentPet.petImage1,
            petImage2: buildPetImageUrl(response.data['petImage2']) ?? currentPet.petImage2,
            petImage3: buildPetImageUrl(response.data['petImage3']) ?? currentPet.petImage3,
            sex: currentPet.sex,
            petBio: currentPet.petBio,
            birthDate: currentPet.birthDate,
            species: currentPet.species,
          );
          
          // Actualizar la mascota en la lista
          pets[selectedPetIndex] = updatedPet;
          notifyListeners();
        }
      } else {
        throw Exception('Error al actualizar imágenes: ${response.statusCode}');
      }
      
    } catch (e) {
      print('Error al actualizar imágenes de mascota: $e');
      rethrow; // Propagar error para manejarlo en la UI
    }
  }
  
  /// Guarda los datos del usuario y la mascota actual
  Future<void> saveAllData() async {
    if (isSaving) return; // Evitar múltiples guardados simultáneos
    
    isSaving = true;
    notifyListeners();
    
    try {
      // Guardar la biografía de la mascota actual antes de enviar
      if (pets.isNotEmpty) {
        saveCurrentPetData();
      }
      
      // --- ACTUALIZAR SOLO LA BIOGRAFÍA DEL USUARIO ---
      Map<String, dynamic> userData = {
        'userUID': userId,
        'userBio': userBioController.text,
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
      
    } catch (e) {
      print('Error al guardar datos: $e');
      rethrow; // Propagar error para manejarlo en la UI
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
  
  /// Actualiza la biografía de la mascota actual
  void updatePetBio(String text) {
    if (pets.isEmpty) return;
    
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
    notifyListeners();
  }
  
  /// Limpia los recursos al finalizar
  @override
  void dispose() {
    userNameController.dispose();
    userAgeController.dispose();
    userSexController.dispose();
    userLocationController.dispose();
    userBioController.dispose();
    nameController.dispose();
    ageController.dispose();
    speciesController.dispose();
    sexController.dispose();
    bioController.dispose();
    super.dispose();
  }
  
  /// Indica si el usuario tiene mascotas
  bool get hasPets => pets.isNotEmpty;
}