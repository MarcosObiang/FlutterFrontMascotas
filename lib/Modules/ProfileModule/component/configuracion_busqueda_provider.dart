import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TipoBusqueda {
  todas,
  // porProximidad, // Opción comentada
  porEspecie,
}

class ConfiguracionBusquedaProvider extends ChangeNotifier {
  // Valores predeterminados
  TipoBusqueda _tipoBusquedaSeleccionado = TipoBusqueda.todas;
  String _especieSeleccionada = 'Todas';
  double _distanciaMaxima = 20.0;
  bool _notificacionesActivas = true;
  
  // Claves para SharedPreferences
  static const String _keyTipoBusqueda = 'tipo_busqueda';
  static const String _keyEspecieSeleccionada = 'especie_seleccionada';
  static const String _keyDistanciaMaxima = 'distancia_maxima';
  static const String _keyNotificaciones = 'notificaciones_activas';
  
  // Mapear los nombres en español a los valores de enum
  final Map<String, TipoBusqueda> _mapaNombresTipoBusqueda = {
    'Todas las mascotas': TipoBusqueda.todas,
    // 'Por proximidad': TipoBusqueda.porProximidad, // Opción comentada
    'Por especie': TipoBusqueda.porEspecie,
  };
  
  // Mapear las especies en español a los valores en inglés para la API
  final Map<String, String> _mapaEspeciesAPI = {
    'Perro': 'dog',
    'Gato': 'cat',
    'Ave': 'bird',
    'Conejo': 'rabbit',
    'Hamster': 'hamster',
    'Otro': 'other',
    'Todas': 'all',
  };
  
  // Getters
  TipoBusqueda get tipoBusquedaSeleccionado => _tipoBusquedaSeleccionado;
  String get especieSeleccionada => _especieSeleccionada;
  double get distanciaMaxima => _distanciaMaxima;
  bool get notificacionesActivas => _notificacionesActivas;
  
  // Getter para obtener el nombre en español del tipo de búsqueda actual
  String get nombreTipoBusqueda {
    switch (_tipoBusquedaSeleccionado) {
      case TipoBusqueda.todas:
        return 'Todas las mascotas';
      // case TipoBusqueda.porProximidad:
      //   return 'Por proximidad';
      case TipoBusqueda.porEspecie:
        return 'Por especie';
      default:
        return 'Todas las mascotas';
    }
  }
  
  // Getter para obtener el nombre de la especie para la API (en inglés)
  String get especieSeleccionadaAPI {
    return _mapaEspeciesAPI[_especieSeleccionada] ?? 'all';
  }
  
  // Setters
  void setTipoBusqueda(TipoBusqueda tipo) {
    _tipoBusquedaSeleccionado = tipo;
    notifyListeners();
  }
  
  void setTipoBusquedaPorNombre(String nombre) {
    _tipoBusquedaSeleccionado = _mapaNombresTipoBusqueda[nombre] ?? TipoBusqueda.todas;
    notifyListeners();
  }
  
  void setEspecieSeleccionada(String especie) {
    _especieSeleccionada = especie;
    notifyListeners();
  }
  
  void setDistanciaMaxima(double distancia) {
    _distanciaMaxima = distancia;
    notifyListeners();
  }
  
  void setNotificacionesActivas(bool activas) {
    _notificacionesActivas = activas;
    notifyListeners();
  }
  
  // Método para obtener las especies disponibles en español
  List<String> getEspeciesDisponibles() {
    return _mapaEspeciesAPI.keys.toList();
  }
  
  // Método para cargar las preferencias guardadas
  Future<void> cargarPreferencias() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Cargamos el tipo de búsqueda
      final tipoBusquedaIndex = prefs.getInt(_keyTipoBusqueda) ?? TipoBusqueda.todas.index;
      // Validamos que el índice sea válido para los valores disponibles
      if (tipoBusquedaIndex < TipoBusqueda.values.length) {
        _tipoBusquedaSeleccionado = TipoBusqueda.values[tipoBusquedaIndex];
      } else {
        _tipoBusquedaSeleccionado = TipoBusqueda.todas;
      }
      
      // Cargamos la especie seleccionada
      _especieSeleccionada = prefs.getString(_keyEspecieSeleccionada) ?? 'Todas';
      
      // Cargamos la distancia máxima
      _distanciaMaxima = prefs.getDouble(_keyDistanciaMaxima) ?? 20.0;
      
      // Cargamos la configuración de notificaciones
      _notificacionesActivas = prefs.getBool(_keyNotificaciones) ?? true;
      
      notifyListeners();
    } catch (e) {
      // En caso de error, mantenemos los valores predeterminados
      print('Error al cargar preferencias: $e');
    }
  }
  
  // Método para guardar las preferencias
  Future<void> guardarPreferencias() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Guardamos el tipo de búsqueda
      await prefs.setInt(_keyTipoBusqueda, _tipoBusquedaSeleccionado.index);
      
      // Guardamos la especie seleccionada
      await prefs.setString(_keyEspecieSeleccionada, _especieSeleccionada);
      
      // Guardamos la distancia máxima
      await prefs.setDouble(_keyDistanciaMaxima, _distanciaMaxima);
      
      // Guardamos la configuración de notificaciones
      await prefs.setBool(_keyNotificaciones, _notificacionesActivas);
      
      return Future.value();
    } catch (e) {
      print('Error al guardar preferencias: $e');
      return Future.error('Error al guardar las preferencias: $e');
    }
  }
  
  // Método para aplicar cambios de criterios de búsqueda
  Future<void> aplicarCambiosBusqueda() async {
    await guardarPreferencias();
    // Aquí se podría disparar una actualización global o notificar a otras partes de la app
  }
}