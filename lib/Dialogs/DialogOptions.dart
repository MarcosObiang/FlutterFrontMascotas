import 'package:flutter/material.dart';

class DialogOptions {
  final VoidCallback function;
  final String text;

  DialogOptions({
    required this.function,
    required this.text,
  });
}

class PositiveDialogOptions extends DialogOptions {
  PositiveDialogOptions({required VoidCallback function, required String text})
      : super(function: function, text: text);
}

class NegativeDialogOptions extends DialogOptions {
  NegativeDialogOptions({required VoidCallback function, required String text})
      : super(function: function, text: text);
}