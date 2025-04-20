import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  /// Solicita y asegura el permiso de ubicación
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Solicita y asegura el permiso de cámara
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Solicita y asegura el permiso de micrófono
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Revisa si un permiso específico está concedido
  Future<bool> isPermissionGranted(Permission permission) async {
    return await permission.isGranted;
  }

  /// Abre la configuración de la app en caso de que el permiso haya sido denegado permanentemente
  Future<void> openAppSettingsIfNeeded(Permission permission) async {
    final status = await permission.status;
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }
}
