abstract class UseCaseInterfacae<T> {
  /// Metodo llamado para ejecutar el usecase.
  /// Contiene toda la logica del usecase.

  Future<T> execute();
}
