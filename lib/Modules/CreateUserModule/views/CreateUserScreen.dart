import 'dart:typed_data';
import 'package:flutter/material.dart';
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

class _CreateuserscreenState extends State<Createuserscreen> with SingleTickerProviderStateMixin {
  // Controladores y servicios
  final SignUpUseCase signUpUseCase = getIt<SignUpUseCase>();
  final CreateUserState createUserState = getIt<CreateUserState>();
  final TextEditingController nameTextEditingController = TextEditingController();
  final TextEditingController bioTextEditingController = TextEditingController();
  final TextEditingController petSpeciesEditignController = TextEditingController();
  final TextEditingController petBioTextEditingController = TextEditingController();
  final TextEditingController petNameTextEditingController = TextEditingController();
  final PageController pageController = PageController();
  
  // Animación para transiciones
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Variables para control de datos
  DateTime? _selectedDate;
  DateTime? selectedPetDate;
  Uint8List? userImage;
  Uint8List? petImage;
  
  // Focus Nodes
  FocusNode nameInputFocusNode = FocusNode();
  FocusNode bioFocusNode = FocusNode();
  FocusNode petFocusNode = FocusNode();
  FocusNode petBioFocusNode = FocusNode();

  // Datos del usuario
  int age = 0;
  int petAge = 0;
  String bio = "";
  String petBio = "";
  String sex = "male";
  String petSex = "male";
  String userName = "";
  String petName = "";
  String petSpecies = "";

  @override
  void initState() {
    super.initState();
    // Configurar animación
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn)
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    nameInputFocusNode.dispose();
    bioFocusNode.dispose();
    petFocusNode.dispose();
    petBioFocusNode.dispose();
    pageController.dispose();
    nameTextEditingController.dispose();
    bioTextEditingController.dispose();
    petSpeciesEditignController.dispose();
    petBioTextEditingController.dispose();
    petNameTextEditingController.dispose();
    super.dispose();
  }

  // Function to show the date picker
  Future<void> _presentDatePicker(bool isPetBirthDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isPetBirthDate 
          ? (selectedPetDate ?? DateTime.now().subtract(const Duration(days: 365 * 3)))
          : (_selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 18))),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isPetBirthDate) {
          selectedPetDate = picked;
          petAge = calculateAge(selectedPetDate!);
        } else {
          _selectedDate = picked;
          age = calculateAge(_selectedDate!);
        }
      });
    }
  }

  // Función para calcular la edad
  int calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;

    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month && currentDate.day < birthDate.day)) {
      age--;
    }

    return age < 0 ? 0 : age;
  }

  Future<void> _pickImage(bool isPetImage) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (pickedImage == null) return;
      
      final bytes = await pickedImage.readAsBytes();
      
      setState(() {
        if (isPetImage) {
          petImage = bytes;
        } else {
          userImage = bytes;
        }
      });
    } catch (e) {
      PresentationDialogs().showErrorDialog(
        title: "Error",
        content: "No se pudo cargar la imagen. Inténtalo de nuevo.",
        context: context,
      );
    }
  }

  void _navigateToNextPage() {
    // Validaciones para la primera página
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

    // Animación de transición
    _animationController.reverse().then((_) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeInOut
      );
      _animationController.forward();
    });
  }

  void _submitRegistration() {
    // Validaciones para la segunda página
    if (petName.isEmpty) {
      PresentationDialogs().showErrorDialog(
          title: "Error",
          content: "Por favor, introduce el nombre de tu mascota",
          context: context);
      return;
    }

    if (petImage == null) {
      PresentationDialogs().showErrorDialog(
          title: "Error",
          content: "Por favor, selecciona una foto para tu mascota",
          context: context);
      return;
    }

    if (petSpecies.isEmpty) {
      PresentationDialogs().showErrorDialog(
          title: "Error",
          content: "Por favor, elige una especie",
          context: context);
      return;
    }

    // Enviar datos
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
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primaryColor = theme.primaryColor;
    final Color secondaryColor = theme.colorScheme.secondary;
    
    return ChangeNotifierProvider.value(
      value: createUserState,
      child: Consumer<CreateUserState>(
        builder: (context, createUserState, child) {
          return Scaffold(
            backgroundColor: Color.fromRGBO(242, 217, 208, 1),
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                "Registro",
                style: TextStyle(
                  color: Colors.pink,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              iconTheme: IconThemeData(color: Colors.pink),
            ),
            body: createUserState.getCreateUserStatus == CreateUserStatus.loading
                ? loadingPage(primaryColor)
                : createUserState.getCreateUserStatus == CreateUserStatus.error
                    ? errorPage(primaryColor, secondaryColor)
                    : createUserState.getCreateUserStatus == CreateUserStatus.success
                        ? successPage(context, primaryColor)
                        : FadeTransition(
                            opacity: _fadeAnimation,
                            child: PageView(
                              physics: const NeverScrollableScrollPhysics(),
                              controller: pageController,
                              children: [
                                page1(primaryColor, secondaryColor),
                                page2(primaryColor, secondaryColor),
                              ],
                            ),
                          ),
          );
        },
      ),
    );
  }

  Center successPage(BuildContext context, Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 180.w,
            color: Colors.green,
          ),
          SizedBox(height: 30.h),
          Text(
            "¡Cuenta creada con éxito!",
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            "Ahora puedes comenzar a usar la aplicación",
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 40.h),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/navigation');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              minimumSize: Size(200.w, 50.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 2,
            ),
            child: const Text("Comenzar", style: TextStyle(fontSize: 16)),
          )
        ],
      ),
    );
  }

  Center loadingPage(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryColor),
          SizedBox(height: 30.h),
          Text(
            "Creando tu cuenta...",
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Center errorPage(Color primaryColor, Color secondaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 150.w,
            color: Colors.red,
          ),
          SizedBox(height: 20.h),
          Text(
            "Error al crear tu cuenta",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Text(
              createUserState.errorMessage ?? "Por favor, inténtalo de nuevo",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black54,
              ),
            ),
          ),
          SizedBox(height: 30.h),
          ElevatedButton.icon(
            onPressed: _submitRegistration,
            icon: const Icon(Icons.refresh),
            label: const Text("Intentar de nuevo"),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              minimumSize: Size(200.w, 50.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget page1(Color primaryColor, Color secondaryColor) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tus datos personales",
              style: TextStyle(
                fontSize: 60.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              "Cuéntanos un poco sobre ti",
              style: TextStyle(
                fontSize: 30.sp,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 30.h),
            
            // Foto de perfil
            Center(
              child: GestureDetector(
                onTap: () => _pickImage(false),
                child: Stack(
                  children: [
                    Container(
                      height: 300.w,
                      width: 300.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                        image: userImage != null
                            ? DecorationImage(
                                fit: BoxFit.cover,
                                image: MemoryImage(userImage!),
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: userImage == null
                          ? Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.grey[400],
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.pink,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30.h),
            
            // Campo de nombre
            TextFormField(
              focusNode: nameInputFocusNode,
              controller: nameTextEditingController,
              onChanged: (value) {
                setState(() {
                  userName = value;
                });
              },
              style: TextStyle(fontSize: 50.sp),
              decoration: InputDecoration(
                labelText: "Nombre",
                hintText: "Ingresa tu nombre",
                prefixIcon: Icon(Icons.person, color: Colors.pink),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.pink, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            SizedBox(height: 20.h),
            
            // Selector de fecha de nacimiento
            GestureDetector(
              onTap: () {
                nameInputFocusNode.unfocus();
                _presentDatePicker(false);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: age >= 18 ? Colors.grey[300]! : Colors.red,
                    width: age >= 18 ? 1 : 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.pink,
                      size: 22,
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? "Fecha de nacimiento"
                            : "$age años (${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year})",
                        style: TextStyle(
                          fontSize: 30.sp,
                          color: _selectedDate == null ? Colors.grey[600] : Colors.black87,
                          fontWeight: _selectedDate != null ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.pink,
                    ),
                  ],
                ),
              ),
            ),
            if (age > 0 && age < 18)
              Padding(
                padding: EdgeInsets.only(top: 8.h, left: 15.w),
                child: Text(
                  "Debes ser mayor de edad para registrarte",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 30.sp,
                  ),
                ),
              ),
            SizedBox(height: 20.h),
            
            // Selección de sexo
            Text(
              "Sexo",
              style: TextStyle(
                fontSize: 50.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => sex = 'male'),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: sex == 'male' ? Colors.pink.withOpacity(0.1) : Colors.grey[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: sex == 'male' ? Colors.pink : Colors.grey[300]!,
                          width: sex == 'male' ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.male,
                            color: sex == 'male' ? Colors.pink : Colors.grey[600],
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            "Masculino",
                            style: TextStyle(
                              color: sex == 'male' ? Colors.pink : Colors.black87,
                              fontWeight: sex == 'male' ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => sex = 'female'),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: sex == 'female' ? Colors.pink.withOpacity(0.1) : Colors.grey[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: sex == 'female' ? Colors.pink : Colors.grey[300]!,
                          width: sex == 'female' ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.female,
                            color: sex == 'female' ? Colors.pink : Colors.grey[600],
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            "Femenino",
                            style: TextStyle(
                              color: sex == 'female' ? Colors.pink : Colors.black87,
                              fontWeight: sex == 'female' ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            
            // Campo de bio
            TextField(
              focusNode: bioFocusNode,
              controller: bioTextEditingController,
              maxLength: 200,
              maxLines: 3,
              onChanged: (value) {
                setState(() {
                  bio = value;
                });
              },
              style: TextStyle(fontSize: 50.sp),
              decoration: InputDecoration(
                labelText: "Sobre ti",
                hintText: "Cuéntanos un poco sobre ti...",
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.pink, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            SizedBox(height: 40.h),
            
            // Botón de siguiente
            SizedBox(
              width: double.infinity,
              height: 80.h,
              child: ElevatedButton.icon(
                onPressed: _navigateToNextPage,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(
                  "Siguiente",
                  style: TextStyle(
                    fontSize: 50.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget page2(Color primaryColor, Color secondaryColor) {
    final petSpeciesList = [
      'Perro', 'Gato', 'Pez', 'Pájaro', 'Conejo', 
      'Hamster', 'Cobaya', 'Hurón', 'Tortuga'
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.pink),
                  onPressed: () {
                    _animationController.reverse().then((_) {
                      pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      _animationController.forward();
                    });
                  },
                ),
                Text(
                  "Sobre tu mascota",
                  style: TextStyle(
                    fontSize: 50.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: 50.w),
              child: Text(
                "Cuéntanos sobre tu compañero peludo",
                style: TextStyle(
                  fontSize: 30.sp,
                  color: Colors.black54,
                ),
              ),
            ),
            SizedBox(height: 30.h),
            
            // Foto de la mascota
            Center(
              child: GestureDetector(
                onTap: () => _pickImage(true),
                child: Stack(
                  children: [
                    Container(
                      height: 300.w,
                      width: 300.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                        image: petImage != null
                            ? DecorationImage(
                                fit: BoxFit.cover,
                                image: MemoryImage(petImage!),
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: petImage == null
                          ? Icon(
                              Icons.pets,
                              size: 80,
                              color: Colors.grey[400],
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.pink,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30.h),
            
            // Campo de nombre de mascota
            TextFormField(
              focusNode: petFocusNode,
              controller: petNameTextEditingController,
              onChanged: (value) {
                setState(() {
                  petName = value;
                });
              },
              style: TextStyle(fontSize: 50.sp),
              decoration: InputDecoration(
                labelText: "Nombre de tu mascota",
                hintText: "¿Cómo se llama?",
                prefixIcon: Icon(Icons.pets, color: Colors.pink),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.pink, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            SizedBox(height: 20.h),
            
            // Selector de fecha de nacimiento de mascota
            GestureDetector(
              onTap: () {
                petFocusNode.unfocus();
                _presentDatePicker(true);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.pink!,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.pink,
                      size: 22,
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: Text(
                        selectedPetDate == null
                            ? "Fecha de nacimiento"
                            : "$petAge años (${selectedPetDate!.day}/${selectedPetDate!.month}/${selectedPetDate!.year})",
                        style: TextStyle(
                          fontSize: 30.sp,
                          color: selectedPetDate == null ? Colors.grey[600] : Colors.black87,
                          fontWeight: selectedPetDate != null ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            
            // Selección de sexo de mascota
            Text(
              "Sexo de tu mascota",
              style: TextStyle(
                fontSize: 50.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => petSex = 'male'),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: petSex == 'male' ? Colors.pink.withOpacity(0.1) : Colors.grey[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: petSex == 'male' ? Colors.pink : Colors.grey[300]!,
                          width: petSex == 'male' ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.male,
                            color: petSex == 'male' ? Colors.pink : Colors.grey[600],
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            "Macho",
                            style: TextStyle(
                              color: petSex == 'male' ? Colors.pink : Colors.black87,
                              fontWeight: petSex == 'male' ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => petSex = 'female'),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: petSex == 'female' ? Colors.pink.withOpacity(0.1) : Colors.grey[50],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: petSex == 'female' ? Colors.pink : Colors.grey[300]!,
                          width: petSex == 'female' ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.female,
                            color: petSex == 'female' ? Colors.pink : Colors.grey[600],
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            "Hembra",
                            style: TextStyle(
                              color: petSex == 'female' ? Colors.pink : Colors.black87,
                              fontWeight: petSex == 'female' ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            
            // Selector de especie
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.pink!,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: petSpecies.isEmpty ? null : petSpecies,
                  hint: Text("Especie de tu mascota", style: TextStyle(color: Colors.grey[600])),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                  style: TextStyle(color: Colors.black87, fontSize: 50.sp),
                  onChanged: (String? newValue) {
                    setState(() {
                      petSpecies = newValue!;
                    });
                  },
                  items: ['Perro', 'Gato', 'Pez', 'Pájaro', 'Conejo', 
                        'Hamster', 'Cobaya', 'Hurón', 'Tortuga']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            
            // Campo de bio de mascota
            TextField(
              focusNode: petBioFocusNode,
              controller: petBioTextEditingController,
              maxLength: 200,
              maxLines: 3,
              onChanged: (value) {
                setState(() {
                  petBio = value;
                });
              },
              style: TextStyle(fontSize: 50.sp),
              decoration: InputDecoration(
                labelText: "Sobre tu mascota",
                hintText: "Cuéntanos un poco sobre tu mascota...",
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.pink, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            SizedBox(height: 40.h),
            
            // Botón de registro
            SizedBox(
              width: double.infinity,
              height: 80.h,
              child: ElevatedButton.icon(
                onPressed: _submitRegistration,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(
                  "Completar registro",
                  style: TextStyle(
                    fontSize: 50.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
}