class ModuleException implements Exception {
  String message;
  String title;

  ModuleException(
      {required this.message, required this.title,});

  @override
  String toString() {
    return 'ModuleException{message: $message, title: $title}';
  }
}
