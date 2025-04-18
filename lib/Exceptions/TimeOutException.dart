import 'package:mascotas_citas/Exceptions/ModuleException.dart';

class TimeOutException extends ModuleException {
  TimeOutException(
      {required super.message, required super.title, required super.content});
}
