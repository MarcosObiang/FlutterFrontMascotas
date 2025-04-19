// lib/Resources/Services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/mascota_api.dart';
import '../Models/usuario.dart';

class ApiService {
  static const String _baseUrlPets = 'http://localhost:8083';
  static const String _baseUrlUsers = 'http://localhost:8082';
  static const String _baseUrlLikes = 'http://localhost:8084'; // Nuevo URL para servicio de likes
  
  // Método para obtener todas las mascotas
  Future<List<Mascota>> getAllPets() async {
    final response = await http.get(Uri.parse('$_baseUrlPets/pets/get-all-pets'));
    
    if (response.statusCode == 200) {
      final List<dynamic> petsJson = jsonDecode(response.body);
      
      // Obtener todos los usuarios para mapear propietarios
      final Map<String, Map<String, dynamic>> userMap = await _getUserMap();
      
      // Mapear cada mascota con su propietario
      return petsJson.map((petJson) {
        final ownerUID = petJson['ownerUID'];
        final ownerData = userMap[ownerUID] ?? {};
        return Mascota.fromJson(petJson, ownerData);
      }).toList();
    } else {
      throw Exception('Error al cargar las mascotas: ${response.statusCode}');
    }
  }
  
  // Método para obtener todos los usuarios
  Future<List<Usuario>> getAllUsers() async {
    final response = await http.get(Uri.parse('$_baseUrlUsers/users/all'));
    
    if (response.statusCode == 200) {
      final List<dynamic> usersJson = jsonDecode(response.body);
      return usersJson.map((userJson) => Usuario.fromJson(userJson)).toList();
    } else {
      throw Exception('Error al cargar los usuarios: ${response.statusCode}');
    }
  }
  
  // Método para obtener un mapa de usuarios por ID
  Future<Map<String, Map<String, dynamic>>> _getUserMap() async {
    final response = await http.get(Uri.parse('$_baseUrlUsers/users/all'));
    
    if (response.statusCode == 200) {
      final List<dynamic> usersJson = jsonDecode(response.body);
      
      // Crear un mapa donde la clave es el ID del usuario
      Map<String, Map<String, dynamic>> userMap = {};
      for (var user in usersJson) {
        userMap[user['userUID']] = user;
      }
      
      return userMap;
    } else {
      throw Exception('Error al cargar los usuarios: ${response.statusCode}');
    }
  }
  
  // Método para obtener un usuario por ID
  Future<Usuario> getUserById(String userId) async {
    final response = await http.get(Uri.parse('$_baseUrlUsers/users/$userId'));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> userJson = jsonDecode(response.body);
      return Usuario.fromJson(userJson);
    } else {
      throw Exception('Error al cargar el usuario: ${response.statusCode}');
    }
  }
  
  // NUEVOS MÉTODOS PARA EL SERVICIO DE LIKES
  
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
  Future<List<Mascota>> getLikedPetsWithDetails(String userId) async {
    // Primero obtenemos los IDs de las mascotas con like
    final List<String> likedPetIds = await getLikedPetsByUser(userId);
    
    // Después obtenemos todas las mascotas
    final List<Mascota> allPets = await getAllPets();
    
    // Filtramos las mascotas que tienen like
    return allPets.where((pet) => likedPetIds.contains(pet.id)).toList();
  }
  
  // Método para obtener mascotas con matches completos (detalles incluidos)
  Future<List<Mascota>> getMatchesWithDetails(String userId) async {
    // Primero obtenemos los IDs de los matches
    final List<String> matchPetIds = await getUserMatches(userId);
    
    // Después obtenemos todas las mascotas
    final List<Mascota> allPets = await getAllPets();
    
    // Filtramos las mascotas que tienen match
    return allPets.where((pet) => matchPetIds.contains(pet.id)).toList();
  }
}