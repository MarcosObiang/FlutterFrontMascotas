import 'package:mascotas_citas/Exceptions/ModuleException.dart';

abstract class ModuleState<T> {
  void initialize();
  void dispose();
  void setData(T data);
  void setError(ModuleException e);
}
