import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mascotas_citas/Modules/ProfileModule/model/PetSettingsModel.dart';
import 'package:mascotas_citas/Modules/ProfileModule/state/settingsState.dart';
import 'package:mascotas_citas/Modules/ProfileModule/usecases/AddPetUseCase.dart';
import 'package:mascotas_citas/Modules/ProfileModule/usecases/UpdateUserBioUseCase.dart';
import 'package:mascotas_citas/Modules/ProfileModule/usecases/UpdateUserImageUseCase.dart';
import 'package:mascotas_citas/dependencies/injector.dart';
import 'package:mascotas_citas/models/PetModel.dart';
import 'dart:io';
import 'package:mascotas_citas/services/auth/AuthSesionDataService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TextEditingController userBioTextEditingController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Es más seguro acceder a 'data' después de que el widget se haya construido y 'Consumer' lo proporcione.
    // O asegurar que 'data' no sea null aquí, por ejemplo, esperando a que se cargue.
    // Por ahora, lo inicializaremos vacío o lo moveremos a un punto donde 'data' esté disponible.
    // userBioTextEditingController.text = getIt<SettingsState>().data?.userBio ?? "";
  }

  Future<void> _showEditBioDialog(
      BuildContext context, String currentBio) async {
    final TextEditingController bioController =
        TextEditingController(text: currentBio);
    final newBio = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled:
          true, // Permite que el bottom sheet se ajuste al teclado
      builder: (BuildContext bc) {
        return Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(bc).viewInsets.bottom, // Ajuste para el teclado
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Editar Biografía',
                  style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 16),
              TextField(
                controller: bioController,
                maxLines: 5,
                maxLength: 300,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Tu biografía',
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                child: Text('Guardar'),
                onPressed: () {
                  getIt<Updateuserbiousecase>()
                      .execute(userBIo: bioController.text);
                  Navigator.pop(bc, bioController.text);
                },
              ),
              SizedBox(height: 8), // Espacio antes de que el teclado aparezca
            ],
          ),
        );
      },
    );

    if (newBio != null && newBio != currentBio) {
      // Aquí actualizas el estado y/o llamas a tu ViewModel/Repo para guardar el cambio
      setState(() {
        userBioTextEditingController.text =
            newBio; // Actualiza el controlador local
        // Si estás usando SettingsState para manejar la bio, actualízala también:
        // Esto requeriría un método en SettingsState o un ViewModel para persistir el cambio.
        // Por ejemplo: getIt<SettingsState>().updateUserBio(newBio);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Biografía actualizada')),
      );
    }
  }

  Future<void> _pickImage(SettingsState settingsState) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      getIt<Updateuserimageusecase>().execute(bytes);
    }
  }

  Future<PetSettingsModel?> _showAddPetDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController speciesController = TextEditingController();
    final TextEditingController sexController = TextEditingController();
    final TextEditingController birthDateController = TextEditingController();
    final TextEditingController bioController = TextEditingController();
    // Mover _selectedSpecies y _dialogPetImage1 para que StatefulBuilder pueda accederlos y actualizarlos
    // String _selectedSpecies = 'Perro'; // Se manejará dentro de StatefulBuilder

    DateTime? selectedDate;
    File?
        _dialogPetImage1; // Para almacenar la imagen seleccionada en el diálogo

    return showModalBottomSheet<PetSettingsModel?>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bc).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: StatefulBuilder(
              // Usar StatefulBuilder para manejar el estado del diálogo
              builder: (BuildContext context, StateSetter setDialogState) {
                String selectedSpeciesInDialog =
                    'Perro'; // Estado local para especie
                String selectedSexInDialog = 'Macho'; // Estado local para sexo

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text('Añadir Nueva Mascota',
                        style: Theme.of(context).textTheme.titleLarge),
                    SizedBox(height: 24),
                    // Selector de imagen
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final pickedFile = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (pickedFile != null) {
                            setDialogState(() {
                              _dialogPetImage1 = File(pickedFile.path);
                            });
                          }
                        },
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Theme.of(context).colorScheme.primary),
                            image: _dialogPetImage1 != null
                                ? DecorationImage(
                                    image: FileImage(_dialogPetImage1!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _dialogPetImage1 == null
                              ? Icon(Icons.add_a_photo,
                                  size: 50,
                                  color: Theme.of(context).colorScheme.primary)
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Nombre de la mascota',
                      ),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedSpeciesInDialog,
                      decoration: InputDecoration(
                        labelText: 'Especie*',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      items: [
                        'Perro',
                        'Gato',
                        'Ave',
                        'Conejo',
                        'Hámster',
                        'Pez',
                        'Reptil',
                        'Otro'
                      ].map((String species) {
                        return DropdownMenuItem<String>(
                            value: species, child: Text(species));
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setDialogState(() {
                            selectedSpeciesInDialog = newValue;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedSexInDialog,
                      decoration: InputDecoration(
                        labelText: 'Sexo*',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Macho', child: Text('Macho')),
                        DropdownMenuItem(
                            value: 'Hembra', child: Text('Hembra')),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setDialogState(() {
                            selectedSexInDialog = newValue;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: birthDateController,
                      readOnly: true,
                      enabled: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Fecha de Nacimiento',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null && picked != selectedDate) {
                              setDialogState(() {
                                selectedDate = picked;
                                birthDateController.text =
                                    "${picked.toLocal()}".split(' ')[0];
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: bioController,
                      maxLines: 3,
                      maxLength: 300,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Biografía de la mascota',
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      child: Text('Guardar Mascota'),
                      onPressed: () {
                        PetSettingsModel pet = PetSettingsModel(
                            name: nameController.text,
                            petUID: "asdffffff",
                            species: selectedSpeciesInDialog,
                            sex: selectedSexInDialog,
                            birthDate: selectedDate ?? DateTime.now(),
                            petBio: bioController.text,
                            ownerUID: getIt<AuthDataService>().userUID ?? "",
                            age: 0,
                            petImageUID: "")
                          ..image = _dialogPetImage1?.readAsBytesSync();

                        getIt<Addpetusecase>().execute(pet);

                      //  Navigator.pop(bc); // Cierra el diálogo
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'Funcionalidad "Guardar Mascota" pendiente de implementación completa.')));
                      },
                    ),
                    SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildUsuarioTab(BuildContext context, SettingsState settingsState) {
    // Inicializar el controlador aquí si aún no lo ha hecho y los datos están disponibles
    if (userBioTextEditingController.text.isEmpty &&
        (settingsState.data?.userBio.isNotEmpty ?? false)) {
      userBioTextEditingController.text = settingsState.data!.userBio;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          Column(
            // Cambiado de Row a Column
            crossAxisAlignment: CrossAxisAlignment.center, // Centrar la imagen
            children: [
              GestureDetector(
                onTap: () => _pickImage(settingsState),
                child: SizedBox(
                  width: 300.w, // Usar ScreenUtil para el tamaño
                  height: 300.h,
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: settingsState.data?.userImage1 ??
                        "https://via.placeholder.com/150",
                    httpHeaders: {
                      'Authorization':
                          'Bearer ${getIt<AuthDataService>().token}'
                    }, // Usar imagen de placeholder si no hay

                    imageBuilder: (context, imageProvider) => Container(
                      width: 300.w,
                      height: 300.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    placeholder: (context, url) =>
                        Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
              SizedBox(height: 16.h), // Espacio entre la imagen y el texto
              Center(
                // Centrar el texto concatenado

                child: Text(
                  '${settingsState.data?.name ?? 'N/A'},${settingsState.data?.age.toString() ?? 'N/A'}',
                  style:
                      TextStyle(fontSize: 50.sp, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Sexo: ${settingsState.data?.sex ?? 'N/A'}', // Mostrar el sexo si es necesario o eliminarlo
                style: TextStyle(fontSize: 30.sp),
              )
            ],
          ),
          SizedBox(height: 16.h),
          TextField(
            enabled: false, // Para mostrar, no editar directamente aquí
            readOnly: true,
            controller: userBioTextEditingController,
            maxLength: 300,
            maxLines: 3,
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
              labelText: 'Sobre mí',
            ),
          ),
          SizedBox(height: 8.h),
          OutlinedButton.icon(
              onPressed: () {
                _showEditBioDialog(context, userBioTextEditingController.text);
              },
              icon: Icon(Icons.edit),
              label: Text("Editar biografía"))
        ],
      ),
    );
  }

  Widget _buildMascotasTab(BuildContext context, SettingsState settingsState) {
    // Aquí iría el contenido relacionado con las mascotas
    // Por ejemplo, listar las mascotas de settingsState.pets
    return SizedBox(
      height: ScreenUtil().screenHeight,
      width: ScreenUtil().screenWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height: 16.h),
          if (settingsState.pets == null || settingsState.pets!.isEmpty)
            Center(
                child: Text('No tienes mascotas registradas.',
                    style: TextStyle(fontSize: 16.sp)))
          else
            Flexible(
              flex: 6,
              fit: FlexFit.tight,
              child: SizedBox(
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: settingsState.pets!.length,
                  itemBuilder: (context, index) {
                    final pet = settingsState.pets![index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.h),
                      child: ListTile(
                        leading: SizedBox(
                          width: 300.w,
                          height: 300.h,
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: pet.petImageUID ??
                                "https://via.placeholder.com/150",
                            httpHeaders: {
                              'Authorization':
                                  'Bearer ${getIt<AuthDataService>().token}'
                            }, // Usar imagen de placeholder si no hay

                            imageBuilder: (context, imageProvider) => Container(
                              width: 300.w,
                              height: 300.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            placeholder: (context, url) =>
                                Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),

                        title: Text(pet.name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 50.sp)),
                        subtitle: Text('${pet.species} - ${pet.age} años',
                            style: TextStyle(fontSize: 30.sp)),
                        // Puedes añadir más detalles o acciones por mascota aquí
                      ),
                    );
                  },
                ),
              ),
            ),
          Flexible(
              flex: 1,
              fit: FlexFit.loose,
              child: ElevatedButton.icon(
                  onPressed: () async {
                    PetSettingsModel? pet;
                    pet = await _showAddPetDialog(context);
                    print(pet?.toString());
                  },
                  label: Text("Añadir mascota"),
                  icon: Icon(Icons.add)))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: getIt<SettingsState>(),
        child: Consumer<SettingsState>(
          builder: (context, settingsState, child) {
            snackBarHandlelr(settingsState, context);
            return DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  title: Text('Ajustes'),
                  actions: null,
                  automaticallyImplyLeading: false,
                  leading: null,
                  bottom: TabBar(
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    labelColor: Theme.of(context).colorScheme.primary,
                    tabs: [
                      Tab(text: 'Usuario'),
                      Tab(text: 'Mascotas'),
                    ],
                  ),
                ),
                body: TabBarView(
                  children: [
                    _buildUsuarioTab(context, settingsState),
                    _buildMascotasTab(context, settingsState),
                  ],
                ),
              ),
            );
          },
        ));
  }

  void snackBarHandlelr(SettingsState settingsState, BuildContext context) {
    if (settingsState.updateProfilePictureStatus ==
        UpdateProfilePictureStatus.updating) {
      final snackBar = SnackBar(
          content: Row(
        children: [
          Text("Actualizando imagen..."),
          Icon(Icons.update, color: Colors.blue)
        ],
      ));

      WidgetsBinding.instance.scheduleFrameCallback((_) {
        // Mostrar el SnackBar
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        settingsState.setUpdateProfilePictureStatusUpdating(
            UpdateProfilePictureStatus.initial);
      });
    }

    if (settingsState.updateProfilePictureStatus ==
        UpdateProfilePictureStatus.loaded) {
      final snackBar = SnackBar(
          content: Row(
        children: [
          Text('Imagen actualizada con éxito.'),
          Icon(Icons.done, color: Colors.green)
        ],
      ));

      WidgetsBinding.instance.scheduleFrameCallback((_) {
        // Mostrar el SnackBar
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        settingsState.setUpdateProfilePictureStatusUpdating(
            UpdateProfilePictureStatus.initial);
      });
    }

    if (settingsState.updateProfileBioStatus ==
        UpdateProfileBioStatus.updating) {
      final snackBar = SnackBar(
          content: Row(
        children: [
          Text("Actualizando bioiografía..."),
          Icon(Icons.update, color: Colors.blue)
        ],
      ));

      WidgetsBinding.instance.scheduleFrameCallback((_) {
        // Mostrar el SnackBar
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        settingsState
            .setUpdateProfileBioStatusUpdating(UpdateProfileBioStatus.initial);
      });
    }

    if (settingsState.updateProfileBioStatus == UpdateProfileBioStatus.loaded) {
      final snackBar = SnackBar(
          content: Row(
        children: [
          Text('Bioiografía actualizada con éxito.'),
          Icon(Icons.done, color: Colors.green)
        ],
      ));

      WidgetsBinding.instance.scheduleFrameCallback((_) {
        // Mostrar el SnackBar
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        settingsState
            .setUpdateProfileBioStatusUpdating(UpdateProfileBioStatus.initial);
      });
    }
  }
}
