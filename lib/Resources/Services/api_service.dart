// lib/Resources/Services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/mascota_api.dart';
import '../Models/usuario.dart';

class ApiService {
  static const String _baseUrlPets = 'http://localhost:8083';
  static const String _baseUrlUsers = 'http://localhost:8082';
  
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
}