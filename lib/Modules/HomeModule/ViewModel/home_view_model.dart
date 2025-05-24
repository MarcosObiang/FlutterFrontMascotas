import 'package:flutter/material.dart';
import 'package:mascotas_citas/models/PetModel.dart';
import 'package:mascotas_citas/services/ApiService.dart';
import 'package:mascotas_citas/services/auth/AuthSesionDataService.dart';
import 'package:dio/dio.dart';
import 'package:mascotas_citas/services/platform/storage/SecureStorage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mascotas_citas/Modules/ProfileModule/component/configuracion_busqueda_provider.dart';

// Enum para estados de carga
enum LoadingStatus { loading, loaded, error }

class HomeViewModel extends ChangeNotifier {
  // Servicios
  final ApiService _apiService;
  final Dio _dio = Dio();
  
  // Estado
  List<PetModel>? _mascotas;
  LoadingStatus _status = LoadingStatus.loading;
  String? _errorMessage;
  int _currentIndex = 0;
  
  // Getters
  List<PetModel>? get mascotas => _mascotas;
  LoadingStatus get status => _status;
  String? get errorMessage => _errorMessage;
  int get currentIndex => _currentIndex;
  
  // Constructor
  HomeViewModel() : 
    _apiService = ApiService(
      authDataService: AuthDataService(
        secureStorage: SecureStorage()
      )
    );
  
  // Getter para la mascota actual
  PetModel? get mascotaActual {
    if (_mascotas == null || _mascotas!.isEmpty || _currentIndex >= _mascotas!.length) {
      return null;
    }
    return _mascotas![_currentIndex];
  }
  
  // Métodos de navegación y acciones de usuario
  void avanzarMascota() {
    _currentIndex++;
    notifyListeners();
  }
  
  // Método para obtener el UID del usuario actual
  Future<String> _obtenerUsuarioActualUID() async {
    try {
      // Obtenemos el usuario desde el servicio de autenticación
      final authData = await _apiService.authDataService.getUserUID();
      return authData ?? '';
    } catch (e) {
      print('Error al obtener usuario actual: $e');
      return '';
    }
  }
  
  // Método para cargar las mascotas según la configuración actual
  Future<void> cargarMascotas(ConfiguracionBusquedaProvider configProvider) async {
    _status = LoadingStatus.loading;
    _errorMessage = null;
    _currentIndex = 0; // Reinicia el índice al recargar
    notifyListeners();
    
    try {
      switch (configProvider.tipoBusquedaSeleccionado) {
        case TipoBusqueda.todas:
          await _cargarTodasLasMascotas();
          break;
        // case TipoBusqueda.porProximidad:
        //   await _cargarMascotasPorProximidad(configProvider.distanciaMaxima);
        //   break;
        case TipoBusqueda.porEspecie:
          await _cargarMascotasPorEspecie(configProvider.especieSeleccionadaAPI);
          break;
      }
    } catch (e) {
      _status = LoadingStatus.error;
      _errorMessage = 'Error al cargar las mascotas: $e';
      print('Error detallado: $e'); // Para depuración
      notifyListeners();
    }
  }
  
  // Carga todas las mascotas
  Future<void> _cargarTodasLasMascotas() async {
    try {
      final String usuarioActualUID = await _obtenerUsuarioActualUID();
      final response = await _dio.get('http://localhost:8083/pets/get-all-pets');
      
      if (response.statusCode == 200) {
        _procesarRespuestaMascotas(response.data, usuarioActualUID);
      } else {
        _manejarErrorRespuesta(response.statusCode);
      }
    } catch (e) {
      _manejarExcepcion(e);
    }
  }
  
  // Carga mascotas por especie
  Future<void> _cargarMascotasPorEspecie(String especie) async {
    try {
      final String usuarioActualUID = await _obtenerUsuarioActualUID();
      
      // Si es 'all', cargamos todas las mascotas
      if (especie == 'all') {
        await _cargarTodasLasMascotas();
        return;
      }
      
      print('Buscando mascotas por especie: $especie'); // Para depuración
      
      final response = await _dio.get(
        'http://localhost:8083/pets/get-pets-by-species',
        queryParameters: {'species': especie},
      );
      
      if (response.statusCode == 200) {
        _procesarRespuestaMascotas(response.data, usuarioActualUID);
      } else {
        _manejarErrorRespuesta(response.statusCode);
      }
    } catch (e) {
      _manejarExcepcion(e);
    }
  }
  
  // Carga mascotas por proximidad
  Future<void> _cargarMascotasPorProximidad(double radiusInKm) async {
    try {
      final String usuarioActualUID = await _obtenerUsuarioActualUID();
      
      // Primero obtenemos la posición actual
      Position position = await _obtenerPosicionActual();
      
      // Después buscamos usuarios cercanos
      final usuariosResponse = await _dio.get(
        'http://localhost:8082/users/get-users-by-position',
        queryParameters: {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'radiusInKm': radiusInKm,
        },
      );
      
      if (usuariosResponse.statusCode != 200) {
        _manejarErrorRespuesta(usuariosResponse.statusCode);
        return;
      }
      
      // Procesamos la lista de usuarios
      final List<dynamic> usuarios = usuariosResponse.data;
      final List<PetModel> todasLasMascotas = [];
      
      // Por cada usuario, buscamos sus mascotas
      for (var usuario in usuarios) {
        final String ownerUID = usuario['uid'] ?? '';
        if (ownerUID.isEmpty || ownerUID == usuarioActualUID) continue; // Saltamos al usuario actual
        
        final mascotasResponse = await _dio.get(
          'http://localhost:8083/pets/get-pet-data-by-owner',
          queryParameters: {'ownerUID': ownerUID},
        );
        
        if (mascotasResponse.statusCode == 200 && mascotasResponse.data != null) {
          final List<dynamic> mascotasUsuario = mascotasResponse.data;
          
          for (var mascotaData in mascotasUsuario) {
            final PetModel mascota = _convertirAPetModel(mascotaData);
            todasLasMascotas.add(mascota);
          }
        }
      }
      
      _mascotas = todasLasMascotas;
      _status = LoadingStatus.loaded;
      notifyListeners();
      
    } catch (e) {
      _manejarExcepcion(e);
    }
  }
  
  // Método para obtener la posición actual del usuario
  Future<Position> _obtenerPosicionActual() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si los servicios de ubicación están habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Los servicios de ubicación están desactivados.');
    }

    // Verificar permisos de ubicación
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Los permisos de ubicación fueron denegados');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Los permisos de ubicación están permanentemente denegados');
    }

    // Obtenemos la posición actual
    return await Geolocator.getCurrentPosition();
  }
  
  // Procesa la respuesta de la API de mascotas
  void _procesarRespuestaMascotas(List<dynamic> jsonList, String usuarioActualUID) {
    final List<PetModel> todasLasMascotas = jsonList.map((json) => _convertirAPetModel(json)).toList();
    
    // Filtramos para excluir las mascotas del usuario actual
    final List<PetModel> mascotasFiltradas = todasLasMascotas.where((mascota) {
      return mascota.ownerUID != usuarioActualUID;
    }).toList();
    
    _mascotas = mascotasFiltradas;
    _status = LoadingStatus.loaded;
    notifyListeners();
  }
  
  // Convierte un JSON a un objeto PetModel
  PetModel _convertirAPetModel(dynamic json) {
    return PetModel(
      id: json['petUID'] ?? '', // Usamos petUID como id
      name: json['name'] ?? '',
      petImage1: json['petImage1'] ?? '',
      petImage2: json['petImage2'] ?? '',
      petImage3: json['petImage3'] ?? '',
      petUID: json['petUID'] ?? '',
      ownerUID: json['ownerUID'] ?? '',
      sex: json['sex'] ?? '',
      petBio: json['petBio'] ?? '',
      birthDate: json['birthDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['birthDate']) 
          : DateTime.now(),
      species: json['species'] ?? 'No especificado'
    );
  }
  
  // Maneja errores de respuesta HTTP
  void _manejarErrorRespuesta(int? statusCode) {
    _status = LoadingStatus.error;
    _errorMessage = 'Error al cargar las mascotas: Código ${statusCode}';
    notifyListeners();
  }
  
  // Maneja excepciones generales
  void _manejarExcepcion(dynamic e) {
    _status = LoadingStatus.error;
    _errorMessage = 'Error al cargar las mascotas: $e';
    print('Error detallado: $e'); // Para depuración
    notifyListeners();
  }
  
  // Método para dar like
  Future<bool> darLike() async {
    // Verificar que hay una mascota actual
    if (mascotaActual == null) return false;
    
    try {
      final authData = await _apiService.authDataService.getUserUID();
      final String userId = authData ?? '';
      final String petId = mascotaActual!.id ?? '';
      
      // Implementar petición para crear el like usando el ApiService
      final response = await _apiService.post(
        path: '/likes/create-like',
        data: {
          'userId': userId,
          'petId': petId,
        },
      );
      
      final resultado = response.data;
      
      // Avanzamos al siguiente perfil
      avanzarMascota();
      
      // Retornamos si hubo match o no
      return resultado['isMatch'] == true;
    } catch (e) {
      print('Error al dar like: $e');
      return false;
    }
  }
  
  // Método para dar dislike
  void darDislike() {
    avanzarMascota();
  }

  // Método para obtener el texto descriptivo del tipo de búsqueda actual
  String getTipoBusquedaTexto(ConfiguracionBusquedaProvider provider) {
    switch (provider.tipoBusquedaSeleccionado) {
      case TipoBusqueda.todas:
        return 'Mostrando todas las mascotas';
      // case TipoBusqueda.porProximidad:
      //   return 'Mascotas cercanas (${provider.distanciaMaxima.round()} km)';
      case TipoBusqueda.porEspecie:
        return 'Mascotas de especie: ${provider.especieSeleccionada}';
    }
  }
}