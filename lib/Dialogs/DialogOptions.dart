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
  PositiveDialogOptions({required super.function, required super.text});
}

class NegativeDialogOptions extends DialogOptions {
  NegativeDialogOptions({required super.function, required super.text});
}