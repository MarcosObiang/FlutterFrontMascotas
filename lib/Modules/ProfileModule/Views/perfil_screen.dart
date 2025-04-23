// screens/perfil_screen.dart
import 'package:flutter/material.dart';
import '../../../Resources/Widgets/edit_campo_texto.dart';
import '../../../Resources/Widgets/selector_fotos.dart';
import 'package:mascotas_citas/models/PetModel.dart'; // Importar el nuevo modelo
import '../../../Resources/Services/api_service.dart';
import 'ajustes_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  // ID de usuario estático por ahora
  final String userId = 'cr7erbisho';
  
  // API Service
  final ApiService _apiService = ApiService();
  
  // Datos del usuario
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _userAgeController = TextEditingController();
  final TextEditingController _userSexController = TextEditingController();
  final TextEditingController _userLocationController = TextEditingController();
  final TextEditingController _userBioController = TextEditingController();
  String userImage = 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1000';
  
  // Lista de mascotas
  List<PetModel> pets = [];
  List<String> originalPetIds = []; // Para mantener un registro de las mascotas originales
  
  int selectedPetIndex = 0;
  bool isLoading = true;
  bool isSaving = false; // Flag para indicar cuando se están guardando los datos
  
  // Controllers para la mascota actual
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _speciesController;
  late TextEditingController _sexController;
  late TextEditingController _bioController;
  late List<String> petImages;
  
  @override
  void initState() {
    super.initState();
    
    // Inicializar controladores con valores vacíos
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _speciesController = TextEditingController();
    _sexController = TextEditingController();
    _bioController = TextEditingController();
    petImages = [];
    
    // Cargar datos del usuario y sus mascotas
    _loadUserAndPetsData();
  }
  
  // Método para cargar datos del usuario y sus mascotas desde la API
  Future<void> _loadUserAndPetsData() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      // Cargar datos del usuario
      final user = await _apiService.getUserById(userId);
      
      // Actualizar controladores con datos del usuario
      setState(() {
        _userNameController.text = user.name;
        _userAgeController.text = "${DateTime.now().difference(user.birthDate).inDays ~/ 365}";
        _userSexController.text = user.sex;
        _userLocationController.text = "${user.location.coordinates[1]}, ${user.location.coordinates[0]}";
        _userBioController.text = user.userBio;
        if (user.userImage1.isNotEmpty) {
          userImage = user.userImage1;
        }
      });
      
      // Cargar todas las mascotas y filtrar las del usuario actual
      final allPets = await _apiService.getAllPets();
      final userPets = allPets.where((pet) => 
        pet.onwerUID == userId).toList();
      
      setState(() {
        pets = userPets;
        // Guardar los IDs de las mascotas originales para comparar después
        originalPetIds = pets.map((p) => p.id).toList();
        isLoading = false;
        
        if (pets.isNotEmpty) {
          _loadPetData(0);
        }
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        isLoading = false;
      });
      
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e'))
      );
    }
  }
  
  void _loadPetData(int index) {
    if (pets.isEmpty) return;
    
    PetModel pet = pets[index];
    _nameController.text = pet.name;
    _ageController.text = "${DateTime.now().difference(pet.birthDate).inDays ~/ 365}";
    _speciesController.text = pet.spicies;
    _sexController.text = pet.sex;
    _bioController.text = pet.petBio;
    
    // Convertir imágenes en lista
    petImages = [];
    if (pet.petImage1.isNotEmpty) {
      petImages.add(pet.petImage1);
    }
    
    // Nota: Aquí deberías agregar más imágenes si tu modelo las tiene
    // Por ahora solo usamos petImage1 del modelo
  }
  
  void _saveCurrentPetData() {
    if (pets.isEmpty) return;
    
    // Convertir edad a fecha de nacimiento aproximada
    int years = int.tryParse(_ageController.text) ?? 0;
    DateTime approximateBirthDate = DateTime.now().subtract(Duration(days: years * 365));
    
    // Obtener ID existente o crear uno nuevo
    String currentId = pets[selectedPetIndex].id;
    String currentPetUID = pets[selectedPetIndex].petUID.isNotEmpty ? 
                          pets[selectedPetIndex].petUID : 
                          'pet_${DateTime.now().millisecondsSinceEpoch}';
    
    // Crear la mascota actualizada
    PetModel updatedPet = PetModel(
      id: currentId,
      petUID: currentPetUID,
      onwerUID: userId,
      name: _nameController.text,
      petImage1: petImages.isNotEmpty ? petImages[0] : '',
      sex: _sexController.text,
      petBio: _bioController.text,
      birthDate: approximateBirthDate,
      spicies: _speciesController.text,
    );
    
    setState(() {
      // Actualizar la mascota actual
      pets[selectedPetIndex] = updatedPet;
    });
  }
  
  void _changePet(int index) {
    // Guardar datos de la mascota actual antes de cambiar
    _saveCurrentPetData();
    
    setState(() {
      selectedPetIndex = index;
      _loadPetData(index);
    });
  }
  
  void _addNewPet() {
    // Guardar datos de la mascota actual si existe
    if (pets.isNotEmpty) {
      _saveCurrentPetData();
    }
    
    // Crear nueva mascota
    PetModel newPet = PetModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      petUID: '',
      onwerUID: userId,
      name: '',
      petImage1: '',
      sex: '',
      petBio: '',
      birthDate: DateTime.now(),
      spicies: '',
    );
    
    setState(() {
      pets.add(newPet);
      selectedPetIndex = pets.length - 1;
      _loadPetData(selectedPetIndex);
    });
  }
  
  void _deleteCurrentPet() {
    if (pets.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must have at least one pet')),
      );
      return;
    }
    
    final petToDelete = pets[selectedPetIndex];
    
    setState(() {
      pets.removeAt(selectedPetIndex);
      selectedPetIndex = 0;
      _loadPetData(selectedPetIndex);
    });
    
    // Si la mascota ya existía en la base de datos, la eliminamos
    if (originalPetIds.contains(petToDelete.id)) {
      _apiService.deletePet(petToDelete.id).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pet deleted successfully')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting pet: $error')),
        );
      });
    }
  }
  
  void _updateUserPhoto() {
    // Aquí iría la lógica para seleccionar una nueva foto
    // Por simplicidad, solo cambiamos a una foto predefinida
    setState(() {
      userImage = 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=1000';
    });
  }
  
  // Método para guardar todos los datos (usuario y mascotas)
  Future<void> _saveAllData() async {
    if (isSaving) return; // Evitar múltiples guardados simultáneos
    
    setState(() {
      isSaving = true;
    });
    
    try {
      // Guardar la mascota actual antes de enviar todo
      if (pets.isNotEmpty) {
        _saveCurrentPetData();
      }
      
      // 1. Actualizar datos del usuario
      await _apiService.updateUserProfile(
        userId,
        {
          'userBio': _userBioController.text,
          'userImage1': userImage,
          // Solo enviamos los campos editables
        }
      );
      
      // 2. Procesar mascotas: actualizar existentes, crear nuevas
      for (PetModel pet in pets) {
        if (originalPetIds.contains(pet.id)) {
          // Es una mascota existente, actualizar
          await _apiService.updatePet(pet.toJson());
        } else {
          // Es una mascota nueva, crear
          await _apiService.createPet(pet.toJson());
        }
      }
      
      // 3. Buscar mascotas eliminadas
      for (String id in originalPetIds) {
        if (!pets.any((p) => p.id == id)) {
          // Esta mascota fue eliminada, eliminarla en el servidor
          await _apiService.deletePet(id);
        }
      }
      
      // Actualizar la lista de IDs originales
      originalPetIds = pets.map((p) => p.id).toList();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      print('Error saving data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: $e')),
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }
  
  // Método para mostrar la pantalla de ajustes
  void _showSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AjustesScreen(
          userId: userId,
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // Determinar si hay mascotas registradas
    final bool hasPets = pets.isNotEmpty;
    
    return Scaffold(      
      appBar: AppBar(
        title: Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          isSaving 
            ? Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.pink,
                    strokeWidth: 2.0,
                  ),
                ),
              )
            : TextButton(
                onPressed: _saveAllData,
                child: Text('Save', style: TextStyle(color: Colors.pink)),
              ),
        ],
      ),
      body: isLoading 
        ? Center(child: CircularProgressIndicator(color: Colors.pink))
        : SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Perfil del usuario con botón de ajustes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'User Data',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.pink),
                    onPressed: _showSettings,
                    tooltip: 'Settings',
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Foto del usuario
                  GestureDetector(
                    onTap: _updateUserPhoto,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(userImage),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.pink,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  // Datos del usuario (solo Bio es editable)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mostrar nombre (no editable)
                        _showNonEditableField('Name', _userNameController.text, Icons.person),
                        
                        // Mostrar sexo (no editable)
                        _showNonEditableField('Sex', _userSexController.text, Icons.person_outline),
                        
                        // Mostrar edad (no editable)
                        _showNonEditableField('Age', _userAgeController.text, Icons.cake),
                        
                        // Mostrar ubicación (no editable)
                        _showNonEditableField('Location', _userLocationController.text, Icons.location_on),
                        
                        // Bio (editable)
                        EditCampoTexto(
                          label: 'Bio',
                          controller: _userBioController,
                          icon: Icons.description,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),

              // Mensaje para usuarios sin mascota
              if (!hasPets)
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.pink.shade100),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.pets, size: 40, color: Colors.pink),
                      SizedBox(height: 10),
                      Text(
                        'Add your first pet!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink.shade800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Once you register your pet, you can access all features like finding friends for your pet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.pink.shade700),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _addNewPet,
                        icon: Icon(Icons.add, color: Colors.white),
                        label: Text('Add pet', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
              // Contenido relacionado con mascotas (solo visible si tiene mascotas)
              if (hasPets) ...[
                // Selector de mascotas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Pets',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _addNewPet,
                      icon: Icon(Icons.add, color: Colors.white),
                      label: Text('New pet', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Ajuste de tamaño para la lista de mascotas
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: pets.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _changePet(index),
                        child: Container(
                          margin: EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: index == selectedPetIndex ? Colors.pink : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: pets[index].petImage1.isNotEmpty
                                  ? Image.network(
                                      pets[index].petImage1,
                                      height: 50,
                                      width: 50,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      height: 50,
                                      width: 50,
                                      color: Colors.grey[300],
                                      child: Icon(Icons.pets, color: Colors.grey[600], size: 24),
                                    ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                pets[index].name.isEmpty ? 'New' : pets[index].name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: index == selectedPetIndex ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 24),
                
                // Detalles de la mascota seleccionada
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Details of ${_nameController.text.isEmpty ? "New Pet" : _nameController.text}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: _deleteCurrentPet,
                      icon: Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Delete pet',
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Photos of your pet (maximum 3)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                SelectorFotos(
                  fotos: petImages,
                  maxFotos: 3,
                  onFotoPrincipalChanged: (newMainPhoto) {
                    if (petImages.isNotEmpty && petImages.contains(newMainPhoto)) {
                      setState(() {
                        // Mover la foto principal al inicio de la lista
                        petImages.remove(newMainPhoto);
                        petImages.insert(0, newMainPhoto);
                      });
                    }
                  },
                ),
                SizedBox(height: 24),
                
                Text(
                  'Basic information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                EditCampoTexto(
                  label: 'Name',
                  controller: _nameController,
                  icon: Icons.pets,
                ),
                EditCampoTexto(
                  label: 'Sex',
                  controller: _sexController,
                  icon: Icons.person_outline,
                ),
                EditCampoTexto(
                  label: 'Age',
                  controller: _ageController,
                  icon: Icons.cake,
                  keyboardType: TextInputType.number,
                ),
                EditCampoTexto(
                  label: 'Species',
                  controller: _speciesController,
                  icon: Icons.category,
                ),
                SizedBox(height: 24),
                
                Text(
                  'About your pet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _bioController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Describe your pet...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.pink, width: 2),
                    ),
                  ),
                ),
              ],
              
              SizedBox(height: 36),
            ],
          ),
        ),
    );
  }
  
  Widget _showNonEditableField(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.pink),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}