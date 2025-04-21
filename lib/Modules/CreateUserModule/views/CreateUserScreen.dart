import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mascotas_citas/Dialogs/PresentationDialogs.dart';
import 'package:mascotas_citas/Modules/CreateUserModule/state/CreateUserState.dart';
import 'package:mascotas_citas/Modules/CreateUserModule/usecases/CreateUserUseCase.dart';
import 'package:mascotas_citas/dependencies/injector.dart';
import 'package:provider/provider.dart';

class Createuserscreen extends StatefulWidget {
  const Createuserscreen({super.key});

  @override
  State<Createuserscreen> createState() => _CreateuserscreenState();
}

class _CreateuserscreenState extends State<Createuserscreen> {
  final SignUpUseCase signUpUseCase = getIt<SignUpUseCase>();
  final CreateUserState createUserState = getIt<CreateUserState>();
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController bioTextEditingController = TextEditingController();
  TextEditingController petSpeciesEditignController = TextEditingController();
  TextEditingController petBioTextEditingController = TextEditingController();
  TextEditingController petNameTextEditingController = TextEditingController();
  PageController pageController = PageController();

  DateTime? _selectedDate;
  DateTime? selectedPetDate;

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

  // Function to show the date picker
  Future<void> _presentDatePicker(bool isPetBirthDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ??
          DateTime.now()
              .subtract(Duration(days: (365 * 18))), // Initial date shown
      firstDate: DateTime(1900), // Earliest selectable date
      lastDate: DateTime.now(), // Latest selectable date
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        if (isPetBirthDate) {
          selectedPetDate = picked;
          petAge = calculateAge(selectedPetDate!);
        } else {
          _selectedDate = picked;
          age = calculateAge(_selectedDate!);
        }

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

  Future<void> _pickImage(bool isPetImage) async {
    List<XFile>? res = await ImagePicker().pickMultiImage();
    if (res.isEmpty) return;
    if (isPetImage) {
      petImage = await res.first.readAsBytes();
    } else {
      userImage = await res.first.readAsBytes();
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: createUserState,
      child: Consumer<CreateUserState>(builder: (BuildContext context,
          CreateUserState createUserState, Widget? child) {
        return Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true,
          body: createUserState.getCreateUserStatus == CreateUserStatus.loading
              ? loadingPage()
              : createUserState.getCreateUserStatus == CreateUserStatus.error
                  ? errorPage()
                  : createUserState.getCreateUserStatus ==
                          CreateUserStatus.success
                      ? successPage(context)
                      : PageView(
                          physics: NeverScrollableScrollPhysics(),
                          controller: pageController,
                          children: [
                            page1(),
                            page2(),
                          ],
                        ),
        );
      }),
    );
  }

  Center successPage(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 200.w,
            color: Colors.green,
          ),
          SizedBox(
            height: 20.h,
          ),
          Text("Cuenta creada con éxito"),
          SizedBox(
            height: 20.h,
          ),

          ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/homeScreen');
              },
              child: Text("Ir al inicio"))
          //"))
        ],
      ),
    );
  }

  Center loadingPage() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        Text("Creando tu cuenta, por favor espera..."),
      ],
    ));
  }

  Center errorPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 200.w,
            color: Colors.red,
          ),
          SizedBox(
            height: 20.h,
          ),
          Text("Ha habido un error al crear tu cuenta"),
          SizedBox(
            height: 20.h,
          ),
          Text("createUserState.errorMessage"),
          SizedBox(
            height: 20.h,
          ),
          ElevatedButton.icon(
              onPressed: () {
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
                  petBirthDate: selectedPetDate!,
                  petBio: petBio,
                  petSpecies: petSpecies,
                  userImage: userImage!,
                  petImage: petImage!,
                );
              },
              icon: Icon(Icons.arrow_forward_rounded),
              label: Text("Intentar de nuevo"))
        ],
      ),
    );
  }

  Widget page1() {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Tus datos personales")),
              GestureDetector(
                onTap: () async {
                  await _pickImage(false);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 300.w,
                      width: 300.w,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(100),
                          image: userImage == null
                              ? null
                              : DecorationImage(
                                  fit: BoxFit.cover,
                                  image: MemoryImage(userImage!))),
                      child: Center(
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: userImage == null
                              ? Colors.black
                              : Colors.transparent,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50.h,
                    ),
                    Text("Foto de perfil")
                  ],
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              TextFormField(
                focusNode: nameInputFocusNode,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  prefixIconColor: Colors.black,
                  border: OutlineInputBorder(),
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
                height: 20.h,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: age >= 18 ? Colors.black : Colors.red,
                      ),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          age == 0
                              ? Text("Fecha de nacimiento")
                              : Text(
                                  "$age Años",
                                  style: TextStyle(
                                      color: age >= 18
                                          ? Colors.black
                                          : Colors.red),
                                ),
                          IconButton(
                            icon: Icon(Icons.date_range_outlined),
                            onPressed: () {
                              nameInputFocusNode.unfocus();
                              _presentDatePicker(false);
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                  age >= 18
                      ? Text("")
                      : Text("Debes ser mayor de edad para registrarte",
                          style: TextStyle(color: Colors.red))
                ],
              ),
              Align(alignment: Alignment.centerLeft, child: Text("Sexo")),
              SizedBox(
                height: 10.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  // Radio para "Masculino"
                  Radio<String>(
                    value: 'male',
                    groupValue: sex,
                    onChanged: (String? value) {
                      setState(() {
                        sex = value!;
                      });
                    },
                  ),
                  Text('Masculino'),

                  // Radio para "Femenino"
                  Radio<String>(
                    value: 'female',
                    groupValue: sex,
                    onChanged: (String? value) {
                      setState(() {
                        sex = value!;
                      });
                    },
                  ),
                  Text('Femenino'),
                ],
              ),
              SizedBox(
                height: 10.h,
              ),
              TextField(
                focusNode: bioFocusNode,
                maxLength: 200,
                maxLines: 3,
                controller: bioTextEditingController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Sobre ti"),
                ),
                onChanged: (value) {
                  bio = value;
                },
              ),
              SizedBox(
                height: 100.h,
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (userName.isEmpty) {
                    PresentationDialogs().showErrorDialog(
                        title: "Error",
                        content: "Por favor, introduce tu nombre",
                        context: context);
                    return;
                  }

                  if (age < 18) {
                    PresentationDialogs().showErrorDialog(
                        title: "Error",
                        content: "Debes ser mayor de edad para registrarte",
                        context: context);
                    return;
                  }

                  if (userImage == null) {
                    PresentationDialogs().showErrorDialog(
                        title: "Error",
                        content: "Por favor, selecciona una foto de perfil",
                        context: context);
                    return;
                  }

                  pageController.nextPage(
                      duration: Duration(seconds: 1), curve: Curves.easeIn);
                },
                label: Text("Siguiente"),
                icon: Icon(Icons.arrow_forward_rounded),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget page2() {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Sobre tu mascota")),
              GestureDetector(
                onTap: () async {
                  await _pickImage(true);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 300.w,
                      width: 300.w,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(100),
                          image: petImage == null
                              ? null
                              : DecorationImage(
                                  fit: BoxFit.cover,
                                  image: MemoryImage(petImage!))),
                      child: Center(
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: petImage == null
                              ? Colors.black
                              : Colors.transparent,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50.h,
                    ),
                    Text("Foto de mascota")
                  ],
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              TextFormField(
                focusNode: petFocusNode,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  prefixIconColor: Colors.black,
                  border: OutlineInputBorder(),
                  label: Text("Nombre"),
                ),
                controller: petNameTextEditingController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce su nombre';
                  }
                  if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                    return 'El nombre solo debe contener letras y espacios';
                  }
                  return null;
                },
                onChanged: (value) {
                  petName = value;
                },
              ),
              SizedBox(
                height: 20.h,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: age >= 18 ? Colors.black : Colors.red,
                      ),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          age == 0
                              ? Text("Fecha de nacimiento")
                              : Text(
                                  "$petAge Años",
                                  style: TextStyle(
                                      color: petAge >= 18
                                          ? Colors.black
                                          : Colors.red),
                                ),
                          IconButton(
                            icon: Icon(Icons.date_range_outlined),
                            onPressed: () {
                              nameInputFocusNode.unfocus();
                              _presentDatePicker(true);
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                  age >= 18
                      ? Text("")
                      : Text("Debes ser mayor de edad para registrarte",
                          style: TextStyle(color: Colors.red))
                ],
              ),
              Align(alignment: Alignment.centerLeft, child: Text("Sexo")),
              SizedBox(
                height: 10.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  // Radio para "Masculino"
                  Radio<String>(
                    value: 'male',
                    groupValue: sex,
                    onChanged: (String? value) {
                      setState(() {
                        sex = value!;
                      });
                    },
                  ),
                  Text('Macho'),

                  // Radio para "Femenino"
                  Radio<String>(
                    value: 'female',
                    groupValue: sex,
                    onChanged: (String? value) {
                      setState(() {
                        sex = value!;
                      });
                    },
                  ),
                  Text('Hembra'),
                ],
              ),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Elige su especie")),
              Align(
                alignment: Alignment.centerLeft,
                child: DropdownButton<String>(
                  hint: petSpecies == ""
                      ? Text("Elige tu mascota")
                      : Text(petSpecies),
                  items: <String>[
                    'Perro',
                    'Gato',
                    'Pez',
                    'Pájaro',
                    'Conejo',
                    'Hamster',
                    'Cobaya',
                    'Hurón',
                    'Tortuga'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      petSpecies = value!;
                    });
                    print("Mascota seleccionada: $value");
                  },
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              TextField(
                focusNode: petBioFocusNode,
                maxLength: 200,
                maxLines: 3,
                controller: petBioTextEditingController,
                 textInputAction: TextInputAction.done,
                onEditingComplete: () {
                  petFocusNode.unfocus();
                },

                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Sobre tu mascota"),
                ),
                onChanged: (value) {
                  petBio = value;
                },

                
              ),
              SizedBox(
                height: 100.h,
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (petName.isEmpty) {
                    PresentationDialogs().showErrorDialog(
                        title: "Error",
                        content: "Por favor, introduce su nombre",
                        context: context);
                    return;
                  }

                  if (petImage == null) {
                    PresentationDialogs().showErrorDialog(
                        title: "Error",
                        content: "Por favor, selecciona una foto de perfil",
                        context: context);
                    return;
                  }

                  if (petSpecies == "") {
                    PresentationDialogs().showErrorDialog(
                        title: "Error",
                        content: "Por favor, elige una especie",
                        context: context);
                    return;
                  }

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
                    petBirthDate: selectedPetDate!,
                    petBio: petBio,
                    petSpecies: petSpecies,
                    userImage: userImage!,
                    petImage: petImage!,
                  );
                },
                label: Text("Registrar"),
                icon: Icon(Icons.arrow_forward_rounded),
              )
            ],
          ),
        ),
      ),
    );
  }
}
