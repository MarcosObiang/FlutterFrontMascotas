class ModuleException implements Exception {
  String message;
  String title;
  String content;

  ModuleException(
      {required this.message, required this.title, required this.content});

  @override
  String toString() {
    return 'ModuleException{message: $message, title: $title, content: $content}';
  }
}
