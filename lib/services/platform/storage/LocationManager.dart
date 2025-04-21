import 'package:geolocator/geolocator.dart';
import 'package:mascotas_citas/Exceptions/LocationEcxeption.dart';
import 'package:mascotas_citas/models/PetModel.dart';

class LocationManager {
  /// Devuelve la ubicación actual en formato `Location`.
  /// Lanza `LocationException` si ocurre un error.
  Future<Location> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationException(
          title: "Servicio de ubicación deshabilitado",
          message: "El servicio de ubicación está deshabilitado");
    }

    // Comprobar y solicitar permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationException(
            message: "El usuario denegó los permisos de ubicación",
            title: "Permiso de ubicacion denegado");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationException(
          message:
              " Acceda a los ajustes para dar permiso de ubicacion manualmente",
          title: "Permiso de ubicacion denegado permanentemente");
    }

    try {
      // Obtener la ubicación actual
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      return Location(
        type: "Point",
        coordinates: [position.longitude, position.latitude],
      );
    } catch (e) {
      throw LocationException(
          message: "no se pudo obtener la ubicación actual",
          title: "Error al obtener la ubicación actual");
    }
  }
}
