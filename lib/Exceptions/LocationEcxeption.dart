import 'package:mascotas_citas/Exceptions/ModuleException.dart';

class LocationException extends ModuleException {

  LocationException({required super.message, required super.title});

  @override
  String toString() => "LocationException: $message";
}
