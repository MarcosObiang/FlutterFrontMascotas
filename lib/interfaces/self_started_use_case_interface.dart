abstract class ISelfStartedUseCaseInterface {
  /// Metodo llamado para iniciar el usecase de forma automatica.
  /// Este metodo se ejecuta al iniciar cada modulo por el StarterManager.
  /// En esta funcion llamamos al execute del usecase
  /// Se llamará automaticamente al inicio de cada modulo

  Future<void> init();
}
