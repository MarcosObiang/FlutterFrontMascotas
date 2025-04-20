import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mascotas_citas/Modules/CreateUserModule/usecases/CreateUserUseCase.dart';
import 'package:mascotas_citas/dependencies/injector.dart';

class Createuserscreen extends StatefulWidget {
  const Createuserscreen({super.key});

  @override
  State<Createuserscreen> createState() => _CreateuserscreenState();
}

class _CreateuserscreenState extends State<Createuserscreen> {
  final SignUpUseCase signUpUseCase = getIt<SignUpUseCase>();
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController bioTextEditingController = TextEditingController();
  TextEditingController petSpeciesEditignController = TextEditingController();
  TextEditingController petBioTextEditingController = TextEditingController();
  TextEditingController petNameTextEditingController = TextEditingController();

  DateTime? _selectedDate;
  Uint8List? userImage;
  Uint8List? petImage;
  FocusNode nameInputFocusNode = FocusNode();
  FocusNode bioFocusNode = FocusNode();
  FocusNode petFocusNode = FocusNode();
  FocusNode petBioFocusNode = FocusNode();

  int age = 0;
  int petAge = 0;

  String bio = "";
  String petBio = "";

  String sex = "male";
  String petSex = "male";

  String userName = "";
  String petName = "";

  String petSpecies = "";
  DateTime? petBirthDate;

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

  Future<void> _pickImage() async {
    List<XFile>? res = await ImagePicker().pickMultiImage();
    if (res.isEmpty) return;

    userImage = await res.first.readAsBytes();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnBoardingSlider(
        background: [Container(), Container(), Container(), Container()],
        speed: 2,
        headerBackgroundColor: Colors.white,
        pageBackgroundColor: Colors.white,
        finishButtonText: 'Register',
        finishButtonStyle: FinishButtonStyle(
          backgroundColor: Colors.black,
        ),
        onFinish: () async {
          signUpUseCase.execute(
            userUID: '123',
            userName: userName,
            userSex: sex,
            userBirthDate: _selectedDate!,
            userBio: bio,
            datingSexPreference: 'male',
            petUID: 'perro',
            petName: petName,
            petSex: petSex,
            petBirthDate: petBirthDate!,
            petBio: petBio,
            petSpecies: petSpecies,
            userImage: userImage!,
            petImage: petImage!,
          );
        },
        skipTextButton: Text('Skip'),
        totalPage: 4,
        pageBodies: [page1(), page2(), page4(), page3()],
      ),
    );
  }

  Container page1() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                await _pickImage();
              },
              child: Container(
                height: 600.h,
                width: 600.w,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                    image: userImage == null
                        ? null
                        : DecorationImage(image: MemoryImage(userImage!))),
                child: Center(
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color:
                        userImage == null ? Colors.transparent : Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 200.h,
            ),
            SizedBox(
              height: 200.h,
            ),
            TextFormField(
              focusNode: nameInputFocusNode,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                label: Text("Nombre"),
              ),
              controller: nameTextEditingController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, introduce tu nombre';
                }
                if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                  return 'El nombre solo debe contener letras y espacios';
                }
                return null;
              },
              onChanged: (value) {
                userName = value;
              },
            ),
            SizedBox(
              height: 200.h,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("$age Años"),
                OutlinedButton.icon(
                    onPressed: () {
                      nameInputFocusNode.unfocus();
                      _presentDatePicker();
                    },
                    label: Text("Introduce tu fecha de nacimiento")),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget page2() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Text("Cuentanos algo sobre ti"),
          SizedBox(
            height: 200.h,
          ),
          TextField(
            focusNode: bioFocusNode,
            maxLength: 300,
            maxLines: 10,
            controller: bioTextEditingController,
            decoration: InputDecoration(
              label: Text("Bio"),
            ),
            onChanged: (value) {
              bio = value;
            },
          ),
        ],
      ),
    );
  }

  Container page4() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text("Hablanos sobre tu mascota"),
            SizedBox(
              height: 200.h,
            ),
            GestureDetector(
              onTap: () async {
                await _pickImage();
              },
              child: Container(
                height: 600.h,
                width: 600.w,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                    image: petImage == null
                        ? null
                        : DecorationImage(image: MemoryImage(petImage!))),
                child: Center(
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: petImage == null ? Colors.transparent : Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 200.h,
            ),
            SizedBox(
              height: 200.h,
            ),
            TextFormField(
              focusNode: petFocusNode,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                label: Text("Especie"),
              ),
              controller: nameTextEditingController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, introduce la especie de tu mascota';
                }
                if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                  return 'El nombre solo debe contener letras y espacios';
                }
                return null;
              },
              onChanged: (value) {
                userName = value;
              },
            ),
            SizedBox(
              height: 200.h,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("$age Años"),
                OutlinedButton.icon(
                    onPressed: () {
                      nameInputFocusNode.unfocus();
                      _presentDatePicker();
                    },
                    label: Text("Introduce la fecha de nacimiento")),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget page3() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Text("Cuentanos algo sobre tu mascota"),
          SizedBox(
            height: 200.h,
          ),
          TextField(
            focusNode: petBioFocusNode,
            maxLength: 300,
            maxLines: 10,
            controller: petBioTextEditingController,
            decoration: InputDecoration(
              label: Text("Bio"),
            ),
            onChanged: (value) {
              bio = value;
            },
          ),
        ],
      ),
    );
  }
}
