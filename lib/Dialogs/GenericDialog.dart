import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum DialogType { info, warning, success, error }

class GenericDialog extends StatelessWidget {
  final String content;
  final String title;
  final DialogType dialogType;

  const GenericDialog({
    required this.content,
    required this.title,
    this.dialogType = DialogType.info,
  });

  Icon _getIconForType(BuildContext context) {
    switch (dialogType) {
      case DialogType.warning:
        return Icon(Icons.warning, color: Colors.orange,size: 150.sp,);
      case DialogType.success:
        return Icon(Icons.check_circle, color: Colors.green,size: 150.sp);
      case DialogType.error:
        return Icon(Icons.error, color: Colors.red,size: 150.sp);
      case DialogType.info:
      default:
        return Icon(Icons.info, color: Theme.of(context).colorScheme.primary,size: 150.sp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      backgroundColor: Colors.white,
      title: Row(
        children: [
          _getIconForType(context),
          SizedBox(width: 20.w),
          Expanded(child: Text(title)),
        ],
      ),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Entendido"),
        )
      ],
    );
  }
}