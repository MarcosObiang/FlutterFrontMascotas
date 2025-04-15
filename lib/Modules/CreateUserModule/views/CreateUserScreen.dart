import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Createuserscreen extends StatefulWidget {
  const Createuserscreen({super.key});

  @override
  State<Createuserscreen> createState() => _CreateuserscreenState();
}

class _CreateuserscreenState extends State<Createuserscreen> {
  TextEditingController nameTextEditingController = TextEditingController();
  DateTime? _selectedDate;
  FocusNode focusNode = FocusNode();
  int age = 0;

  // Function to show the date picker
  Future<void> _presentDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(), // Initial date shown
      firstDate: DateTime(1900), // Earliest selectable date
      lastDate: DateTime(2101), // Latest selectable date
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        age = calculateAge(_selectedDate!);
         // Update the state with the selected date
      });
    }
  }

  // Función para calcular la edad
  int calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;

    // Ajustar la edad si el cumpleaños de este año aún no ha pasado
    // Comprueba si el mes actual es anterior al mes de nacimiento
    // O si es el mismo mes pero el día actual es anterior al día de nacimiento
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month &&
            currentDate.day < birthDate.day)) {
      age--;
    }

    // Opcional: Asegurarse de que la edad no sea negativa si se selecciona una fecha futura
    // return max(0, age);
    return age < 0 ? 0 : age; // Retorna 0 si la fecha es futura
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                height: 400.h,
                width: 600.w,
                decoration: BoxDecoration(color: Colors.blue),
                child: Center(
                  child: Icon(Icons.camera_alt_outlined),
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              TextField(
                  focusNode: focusNode,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    label: Text("Nombre"),
                  ),
                  controller: nameTextEditingController),
              Row(
                children: [
                  Text(age.toString() + " Años"),
                  OutlinedButton.icon(
                      onPressed: () {
                        focusNode.unfocus();
                        _presentDatePicker();
                      },
                      label: Icon(Icons.calendar_month_outlined)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
