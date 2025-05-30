import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mascotas_citas/models/PetModel.dart';
import 'package:mascotas_citas/services/ApiServiceRD.dart';
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
  
  bool get hasPets => pets.isNotEmpty;
  
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
  /// Inicializa el ViewModel cargando los datos necesarios
void _init() async {
  try {
    // Cargar datos de autenticación
    await _authDataService.loadAll();
    
    // CORRECCIÓN: Obtenemos el userId del AuthDataService
    userId = _authDataService.getUserUID() ?? '';
    
    // Verificar que tenemos un userId válido
    if (userId.isEmpty) {
      print('⚠️ WARNING: No se encontró userId en AuthDataService');
      print('⚠️ El usuario podría necesitar autenticarse nuevamente');
      
      // Marcar como completada la carga inicial aunque no tengamos datos
      _isInitialLoading = false;
      isLoading = false;
      notifyListeners();
      return;
    }
    
    print('✅ User ID obtenido de AuthDataService: "$userId"');
    
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
    
    // Cargar todos los datos del usuario y mascotas
    await loadAllData();
    
  } catch (error) {
    print('❌ Error durante la inicialización: $error');
    
    // Asegurar que los estados se marquen correctamente en caso de error
    _isInitialLoading = false;
    isLoading = false;
    notifyListeners();
    
    // Podrías lanzar una excepción personalizada o manejar específicamente este error
    // throw Exception('Error al inicializar el perfil: $error');
  }
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
        path: 'http://localhost:8082/users/get',
        headers: {'userUID': userId}, // Usar ID del usuario actual
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
  
// VIEWMODEL - Método addNewPet actualizado con mejor manejo de errores
Future<bool> addNewPet({
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
    print('🐾 Iniciando creación de mascota: $name');
    
    // Indicar que estamos cargando
    isSaving = true;
    notifyListeners();
    
    // Crear FormData para manejar los archivos
    FormData formData = FormData();
    
    // Agregar las imágenes con mejor manejo de errores
    try {
      if (petImage1 != null) {
        formData.files.add(MapEntry(
          'petImage1',
          await MultipartFile.fromFile(
            petImage1.path,
            filename: 'pet_image_1.jpg',
          ),
        ));
        print('✅ Imagen 1 agregada correctamente');
      }
      
      if (petImage2 != null) {
        formData.files.add(MapEntry(
          'petImage2',
          await MultipartFile.fromFile(
            petImage2.path,
            filename: 'pet_image_2.jpg',
          ),
        ));
        print('✅ Imagen 2 agregada correctamente');
      }
      
      if (petImage3 != null) {
        formData.files.add(MapEntry(
          'petImage3',
          await MultipartFile.fromFile(
            petImage3.path,
            filename: 'pet_image_3.jpg',
          ),
        ));
        print('✅ Imagen 3 agregada correctamente');
      }
    } catch (imageError) {
      print('⚠️ Error al procesar imágenes: $imageError');
      // Continuar sin lanzar error, las imágenes pueden haberse procesado parcialmente
    }
    
    // Crear JSON para los datos de la mascota
    Map petJson = {
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
    print('📝 JSON de mascota: $petJsonString');
    
    // Agregar el JSON como parte del FormData
    formData.fields.add(MapEntry('petJson', petJsonString));
    
    // Establecer el encabezado userUID para autenticación
    _apiService.dioClient.options.headers['userUID'] = userId;
    
    print('🚀 Enviando solicitud al servidor...');
    
    // Enviar la solicitud POST
    final response = await _apiService.post(
      path: 'http://localhost:8093/api/pets/create', // URL del orquestador
      data: formData,
    );
    
    print('📡 Respuesta del servidor - Status: ${response.statusCode}');
    print('📡 Datos de respuesta: ${response.data}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        // Crear una nueva mascota con la respuesta
        final petData = response.data;
        
        // Validar que tengamos los datos necesarios
        if (petData == null) {
          print('⚠️ Los datos de respuesta son null, pero la mascota se creó');
          // Aún así, consideramos exitoso si el status code es correcto
          return true;
        }
        
        // Procesar la fecha de nacimiento
        DateTime birthDateObj;
        try {
          birthDateObj = DateTime.parse(birthDate);
        } catch (dateError) {
          print('⚠️ Error al parsear fecha de nacimiento: $dateError');
          birthDateObj = DateTime.now();
        }
        
        // Crear el nuevo modelo de mascota con validaciones
        PetModel newPet = PetModel(
          id: petData['id']?.toString() ?? '',
          petUID: petData['petUID']?.toString() ?? '',
          ownerUID: userId,
          name: name,
          petImage1: petData['petImage1'] != null ? buildPetImageUrl(petData['petImage1']) : '',
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
        try {
          loadPetData(selectedPetIndex);
        } catch (loadError) {
          print('⚠️ Error al cargar datos de mascota: $loadError');
          // No es crítico, continuamos
        }
        
        print('✅ Mascota creada exitosamente: ${newPet.name}');
        return true;
        
      } catch (processingError) {
        print('⚠️ Error al procesar respuesta: $processingError');
        print('⚠️ Pero la mascota se creó correctamente en el servidor');
        // La mascota se creó en el servidor, así que retornamos éxito
        return true;
      }
    } else {
      print('❌ Error del servidor: ${response.statusCode}');
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error completo en addNewPet: $e');
    print('❌ Stack trace: ${StackTrace.current}');
    
    // Si es un error de red o servidor, lanzamos la excepción
    if (e.toString().contains('SocketException') || 
        e.toString().contains('TimeoutException') ||
        e.toString().contains('Error del servidor')) {
      rethrow;
    }
    
    // Para otros errores, verificamos si la mascota podría haberse creado
    print('⚠️ Error durante el proceso, pero podría haberse creado la mascota');
    rethrow;
  } finally {
    isSaving = false;
    notifyListeners();
    print('🏁 Finalizando proceso de creación de mascota');
  }
}
// MÉTODO ADICIONAL PARA VERIFICAR SI LA MASCOTA SE CREÓ REALMENTE
// Agregar este método al ViewModel para verificar si la mascota existe
Future<bool> verifyPetCreation(String petName) async {
  try {
    // Recargar la lista de mascotas desde el servidor
    await loadPets();
    
    // Verificar si la mascota con ese nombre existe
    bool petExists = pets.any((pet) => pet.name.toLowerCase() == petName.toLowerCase());
    
    print('🔍 Verificación: ¿Existe la mascota "$petName"? $petExists');
    return petExists;
  } catch (e) {
    print('⚠️ Error al verificar mascota: $e');
    return false;
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

/// Método para actualizar la imagen de perfil del usuario
Future<void> updateUserImage(File imageFile) async {
  try {
    // Indicar que estamos guardando
    isSaving = true;
    notifyListeners();
    
    // Verificar que tenemos un ID válido
    if (userId.isEmpty) {
      throw Exception('ID de usuario no válido');
    }
    
    // Verificar que se ha proporcionado una imagen
    if (!imageFile.existsSync()) {
      throw Exception('Archivo de imagen no válido');
    }
    
    // Crear FormData para manejar el archivo
    FormData formData = FormData();
    
    // Agregar la imagen
    formData.files.add(MapEntry(
      'userImage',
      await MultipartFile.fromFile(
        imageFile.path,
        filename: 'profile_image.${imageFile.path.split('.').last}',
      ),
    ));
    
    // Establecer el encabezado userUID para autenticación
    _apiService.dioClient.options.headers['userUID'] = userId;
    
    // URL exacta del endpoint como se muestra en el backend
    final String url = 'http://localhost:8093/api/users/update-image';
    
    // Realizar la solicitud PUT usando el método put del ApiService
    final response = await _apiService.put(
      path: url,
      data: formData,
    );
    
    if (response.statusCode == 200) {
      print('Imagen de perfil actualizada correctamente');
      
      // Recargar los datos del usuario para obtener la nueva URL de imagen
      await loadUserData();
      
      print('Respuesta: ${response.data}');
    } else {
      throw Exception('Error al actualizar la imagen de perfil: ${response.statusCode}');
    }
  } catch (e) {
    print('Error al actualizar la imagen de perfil: $e');
    throw Exception('No se pudo actualizar la imagen de perfil: $e');
  } finally {
    isSaving = false;
    notifyListeners();
  }
}

/// Método para seleccionar imagen desde galería y actualizarla
Future<void> selectAndUpdateProfileImage() async {
  try {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Comprimir la imagen
      maxWidth: 800,    // Tamaño máximo
      maxHeight: 800,
    );
    
    if (image != null) {
      File imageFile = File(image.path);
      await updateUserImage(imageFile);
    }
  } catch (e) {
    print('Error al seleccionar y actualizar imagen: $e');
    throw Exception('No se pudo seleccionar la imagen: $e');
  }
}

Future<void> updateUserBirthDate(DateTime newBirthDate) async {
  try {
    // Indicar que estamos guardando
    isSaving = true;
    notifyListeners();
    
    // Verificar que tenemos un ID válido
    if (userId.isEmpty) {
      throw Exception('ID de usuario no válido');
    }
    
    // Formatear la fecha como string ISO
    String formattedDate = "${newBirthDate.year}-${newBirthDate.month.toString().padLeft(2, '0')}-${newBirthDate.day.toString().padLeft(2, '0')}";
    
    // Actualizar los datos locales
    _userBirthDate = newBirthDate;
    _userBirthDateStr = formattedDate;
    
    // Calcular y actualizar la edad
    final age = DateTime.now().difference(newBirthDate).inDays ~/ 365;
    userAgeController.text = age.toString();
    
    // URL del endpoint para actualizar fecha de nacimiento
    final String url = 'http://localhost:8082/users/update-birth-date';
    
    // Realizar la solicitud PUT
    final response = await _apiService.put(
      path: url,
      data: {
        'userUID': userId,
        'birthDate': formattedDate,
      },
    );
    
    if (response.statusCode == 200) {
      print('Fecha de nacimiento del usuario actualizada correctamente');
    } else {
      throw Exception('Error al actualizar fecha de nacimiento: ${response.statusCode}');
    }
  } catch (e) {
    print('Error al actualizar fecha de nacimiento del usuario: $e');
    throw Exception('No se pudo actualizar la fecha de nacimiento: $e');
  } finally {
    isSaving = false;
    notifyListeners();
  }
}

/// Método para seleccionar una imagen desde la galería
Future<File?> pickImageFromGallery() async {
  try {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 85,
    );
    
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  } catch (e) {
    print('Error al seleccionar imagen de galería: $e');
    return null;
  }
}

/// Método para tomar una foto con la cámara
Future<File?> takePhotoWithCamera() async {
  try {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 85,
    );
    
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  } catch (e) {
    print('Error al tomar foto con cámara: $e');
    return null;
  }
}

/// Método para seleccionar múltiples imágenes desde la galería
Future<List<File>> pickMultipleImagesFromGallery({int maxImages = 3}) async {
  try {
    final List<XFile> pickedFiles = await _picker.pickMultiImage(
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 85,
    );
    
    List<File> selectedFiles = [];
    
    // Limitar el número de imágenes seleccionadas
    for (int i = 0; i < pickedFiles.length && i < maxImages; i++) {
      selectedFiles.add(File(pickedFiles[i].path));
    }
    
    return selectedFiles;
  } catch (e) {
    print('Error al seleccionar múltiples imágenes: $e');
    return [];
  }
}

/// Método para refrescar todos los datos
Future<void> refreshAllData() async {
  try {
    await loadAllData();
  } catch (e) {
    print('Error al refrescar datos: $e');
    rethrow;
  }
}

/// Método para limpiar recursos cuando el ViewModel se destruye
@override
void dispose() {
  // Limpiar controladores de texto
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

/// Método para validar si los datos de la mascota son válidos antes de guardar
bool validatePetData() {
  return nameController.text.isNotEmpty &&
         speciesController.text.isNotEmpty &&
         sexController.text.isNotEmpty;
}

/// Método para validar si los datos del usuario son válidos
bool validateUserData() {
  return userNameController.text.isNotEmpty &&
         userAgeController.text.isNotEmpty;
}

/// Método para obtener información resumida de la mascota actual
Map<String, dynamic> getCurrentPetSummary() {
  if (pets.isEmpty) {
    return {};
  }
  
  PetModel currentPet = pets[selectedPetIndex];
  final age = DateTime.now().difference(currentPet.birthDate).inDays ~/ 365;
  
  return {
    'name': currentPet.name,
    'species': currentPet.species,
    'age': age,
    'sex': currentPet.sex,
    'imageUrl': currentPet.petImage1,
  };
}

/// Método para obtener información resumida del usuario
Map<String, dynamic> getUserSummary() {
  return {
    'name': userNameController.text,
    'age': userAgeController.text,
    'sex': userSexController.text,
    'location': userLocationController.text,
    'bio': userBioController.text,
    'imageUrl': userImage,
    'birthDate': _userBirthDateStr,
  };
}
}