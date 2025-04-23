// lib/Resources/Services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mascotas_citas/models/PetModel.dart';
import '../Models/usuario.dart'; // Si aún necesitas este modelo

class ApiService {
  static const String _baseUrlPets = 'http://localhost:8083';
  static const String _baseUrlUsers = 'http://localhost:8082';
  static const String _baseUrlLikes = 'http://localhost:8084';
  
  // MÉTODOS PARA MASCOTAS
  
  // Método para obtener todas las mascotas
  Future<List<PetModel>> getAllPets() async {
    final response = await http.get(Uri.parse('$_baseUrlPets/pets/get-all-pets'));
    
    if (response.statusCode == 200) {
      final List<dynamic> petsJson = jsonDecode(response.body);
      
      // Convertir a lista de PetModel
      return petsJson.map((petJson) => PetModel.fromJson(petJson)).toList();
    } else {
      throw Exception('Error al cargar las mascotas: ${response.statusCode}');
    }
  }
  
  // Método para obtener mascotas por propietario
  Future<List<PetModel>> getPetsByOwner(String ownerId) async {
    final response = await http.get(
      Uri.parse('$_baseUrlPets/pets/get-pet-data-by-owner?ownerUID=$ownerId')
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> petsJson = jsonDecode(response.body);
      return petsJson.map((petJson) => PetModel.fromJson(petJson)).toList();
    } else {
      throw Exception('Error al cargar las mascotas del propietario: ${response.statusCode}');
    }
  }

  // Método para crear una mascota
  Future<PetModel> createPet(Map<String, dynamic> petData) async {
    final response = await http.post(
      Uri.parse('$_baseUrlPets/pets/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(petData),
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> petJson = jsonDecode(response.body);
      return PetModel.fromJson(petJson);
    } else {
      throw Exception('Error al crear la mascota: ${response.statusCode}');
    }
  }

  // Método para obtener una mascota por ID
  Future<PetModel> getPetById(String petId) async {
    final response = await http.get(
      Uri.parse('$_baseUrlPets/pets/get-pet-data?petUID=$petId')
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> petJson = jsonDecode(response.body);
      return PetModel.fromJson(petJson);
    } else {
      throw Exception('Error al cargar la mascota: ${response.statusCode}');
    }
  }

  // Método para actualizar una mascota
  Future<void> updatePet(Map<String, dynamic> petData) async {
    final response = await http.post(
      Uri.parse('$_baseUrlPets/pets/update'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(petData),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar la mascota: ${response.statusCode}');
    }
  }

  // Método para eliminar una mascota
  Future<void> deletePet(String petId) async {
    final response = await http.post(
      Uri.parse('$_baseUrlPets/pets/delete'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'petUID': petId,
      },
    );
    
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar la mascota: ${response.statusCode}');
    }
  }

  // Método para obtener mascotas por especie
  Future<List<PetModel>> getPetsBySpecies(String species) async {
    final response = await http.get(
      Uri.parse('$_baseUrlPets/pets/get-pets-by-species?species=$species')
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> petsJson = jsonDecode(response.body);
      return petsJson.map((petJson) => PetModel.fromJson(petJson)).toList();
    } else {
      throw Exception('Error al cargar las mascotas por especie: ${response.statusCode}');
    }
  }

  // Método para obtener mascotas por posición
  Future<List<PetModel>> getPetsByPosition(double latitude, double longitude, double radiusInKm) async {
    final response = await http.get(
      Uri.parse('$_baseUrlPets/pets/get-pets-by-position?latitude=$latitude&longitude=$longitude&radiusInKm=$radiusInKm')
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> petsJson = jsonDecode(response.body);
      return petsJson.map((petJson) => PetModel.fromJson(petJson)).toList();
    } else {
      throw Exception('Error al cargar las mascotas por posición: ${response.statusCode}');
    }
  }
  
  // MÉTODOS PARA USUARIOS
  
  // Método para obtener todos los usuarios
  Future<List<UserModel>> getAllUsers() async {
    final response = await http.get(Uri.parse('$_baseUrlUsers/users/all'));
    
    if (response.statusCode == 200) {
      final List<dynamic> usersJson = jsonDecode(response.body);
      return usersJson.map((userJson) => UserModel.fromJson(userJson)).toList();
    } else {
      throw Exception('Error al cargar los usuarios: ${response.statusCode}');
    }
  }
  
  // Método para obtener un usuario por ID
  Future<UserModel> getUserById(String userId) async {
    final response = await http.get(Uri.parse('$_baseUrlUsers/users/get-user-data?userUID=$userId'));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> userJson = jsonDecode(response.body);
      return UserModel.fromJson(userJson);
    } else {
      throw Exception('Error al cargar el usuario: ${response.statusCode}');
    }
  }

  // Método para crear un usuario
  Future<UserModel> createUser(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$_baseUrlUsers/users/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> userJson = jsonDecode(response.body);
      return UserModel.fromJson(userJson);
    } else {
      throw Exception('Error al crear el usuario: ${response.statusCode}');
    }
  }

  // Método para actualizar un usuario
  Future<void> updateUser(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$_baseUrlUsers/users/update'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el usuario: ${response.statusCode}');
    }
  }

  // Método para eliminar un usuario
  Future<void> deleteUser(String userId) async {
    final response = await http.post(
      Uri.parse('$_baseUrlUsers/users/delete'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'userUID': userId,
      },
    );
    
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar el usuario: ${response.statusCode}');
    }
  }

  // Método para obtener usuarios por posición
  Future<List<UserModel>> getUsersByPosition(double latitude, double longitude, double radiusInKm) async {
    final response = await http.get(
      Uri.parse('$_baseUrlUsers/users/get-users-by-position?latitude=$latitude&longitude=$longitude&radiusInKm=$radiusInKm')
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> usersJson = jsonDecode(response.body);
      return usersJson.map((userJson) => UserModel.fromJson(userJson)).toList();
    } else {
      throw Exception('Error al cargar los usuarios por posición: ${response.statusCode}');
    }
  }
  
  // MÉTODOS PARA EL SERVICIO DE LIKES
  
  // Método para crear un like
  Future<Map<String, dynamic>> createLike(String userId, String petId) async {
    final response = await http.post(
      Uri.parse('$_baseUrlLikes/likes/create'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'userId': userId,
        'petId': petId,
      },
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear like: ${response.statusCode}');
    }
  }
  
  // Método para obtener mascotas a las que un usuario ha dado like
  Future<List<String>> getLikedPetsByUser(String userId) async {
    final response = await http.get(Uri.parse('$_baseUrlLikes/likes/user/$userId'));
    
    if (response.statusCode == 200) {
      final List<dynamic> petIds = jsonDecode(response.body);
      return petIds.map<String>((id) => id.toString()).toList();
    } else {
      throw Exception('Error al obtener likes del usuario: ${response.statusCode}');
    }
  }
  
  // Método para obtener matches de un usuario
  Future<List<String>> getUserMatches(String userId) async {
    final response = await http.get(Uri.parse('$_baseUrlLikes/likes/matches/$userId'));
    
    if (response.statusCode == 200) {
      final List<dynamic> petIds = jsonDecode(response.body);
      return petIds.map<String>((id) => id.toString()).toList();
    } else {
      throw Exception('Error al obtener matches del usuario: ${response.statusCode}');
    }
  }
  
  // Método para obtener las mascotas completas a las que un usuario ha dado like
  Future<List<PetModel>> getLikedPetsWithDetails(String userId) async {
    // Primero obtenemos los IDs de las mascotas con like
    final List<String> likedPetIds = await getLikedPetsByUser(userId);
    
    // Después obtenemos todas las mascotas
    final List<PetModel> allPets = await getAllPets();
    
    // Filtramos las mascotas que tienen like
    return allPets.where((pet) => likedPetIds.contains(pet.id)).toList();
  }
  
  // Método para obtener mascotas con matches completos (detalles incluidos)
  Future<List<PetModel>> getMatchesWithDetails(String userId) async {
    // Primero obtenemos los IDs de los matches
    final List<String> matchPetIds = await getUserMatches(userId);
    
    // Después obtenemos todas las mascotas
    final List<PetModel> allPets = await getAllPets();
    
    // Filtramos las mascotas que tienen match
    return allPets.where((pet) => matchPetIds.contains(pet.id)).toList();
  }
  
  // Actualizar foto de usuario
  Future<void> updateUserPhoto(String userId, String photoUrl) async {
    final response = await http.post(
      Uri.parse('$_baseUrlUsers/users/update'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userUID': userId,
        'userImage1': photoUrl,
      }),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar la foto del usuario: ${response.statusCode}');
    }
  }
  
  // Actualizar perfil de usuario
  Future<void> updateUserProfile(String userId, Map<String, dynamic> userData) async {
    // Asegurarse de que el userUID esté incluido en los datos
    userData['userUID'] = userId;
    
    final response = await http.post(
      Uri.parse('$_baseUrlUsers/users/update'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el perfil del usuario: ${response.statusCode}');
    }
  }
}