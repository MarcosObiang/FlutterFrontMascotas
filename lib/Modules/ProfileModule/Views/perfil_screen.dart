import 'package:flutter/material.dart';
import 'package:mascotas_citas/Modules/ProfileModule/ViewModels/perfil_view_model.dart';
import 'package:mascotas_citas/Modules/ProfileModule/Views/ajustes_screen.dart';
import 'package:mascotas_citas/Modules/ProfileModule/component/CreatePetForm.dart';
import 'package:mascotas_citas/Resources/Widgets/selector_fotos.dart';
import 'package:mascotas_citas/models/PetModel.dart';
import 'package:mascotas_citas/services/ApiService.dart';
import 'package:mascotas_citas/services/auth/AuthSesionDataService.dart';
import 'package:mascotas_citas/services/platform/storage/SecureStorage.dart';
import 'package:provider/provider.dart';
import 'package:mascotas_citas/Resources/providers/theme_provider.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  // Constantes para layout y espaciado
  final double _profileImageSize = 100;
  final double _petAvatarSize = 80;
  final double _cardPadding = 16.0;
  final double _sectionSpacing = 24.0;
  final double _itemSpacing = 16.0;
  final double _smallSpacing = 8.0;
  
  // Estado para control de edición de biografías
  bool _isEditingUserBio = false;
  bool _isEditingPetBio = false;
  
  late PerfilViewModel _viewModel;
  
  @override
  void initState() {
    super.initState();
    
    // Inicializar el ViewModel con los servicios necesarios
    final apiService = ApiService(
      authDataService: AuthDataService(secureStorage: SecureStorage()),
    );
    
    final authDataService = AuthDataService(secureStorage: SecureStorage());
    
    // Crear el ViewModel
    _viewModel = PerfilViewModel(
      apiService: apiService,
      authDataService: authDataService,
    );
  }
  
  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  /// Formatea la fecha de cumpleaños al formato dd-mm-aaaa
  String _formatBirthday(DateTime? birthday) {
    if (birthday == null) {
      return 'No especificado';
    }
    
    // Formatear con ceros a la izquierda para días y meses de un dígito
    String day = birthday.day.toString().padLeft(2, '0');
    String month = birthday.month.toString().padLeft(2, '0');
    String year = birthday.year.toString();
    
    return '$day-$month-$year';
  }
  
  /// Calcula la edad exacta en años, meses y días con formato en español
String _calculateAge(DateTime? birthday) {
  if (birthday == null) {
    return 'No disponible';
  }
  
  final DateTime now = DateTime.now();
  
  // Calcular diferencia en días para manejar años bisiestos correctamente
  final int days = now.difference(birthday).inDays;
  
  // Calcular años, meses y días
  int years = 0;
  int months = 0;
  int remainingDays = days;
  
  // Calcular años
  DateTime tempDate = birthday;
  while (tempDate.add(const Duration(days: 365)).isBefore(now)) {
    final DateTime nextYear = DateTime(tempDate.year + 1, tempDate.month, tempDate.day);
    final int daysInYear = nextYear.difference(tempDate).inDays;
    if (remainingDays >= daysInYear) {
      years++;
      remainingDays -= daysInYear;
      tempDate = nextYear;
    } else {
      break;
    }
  }
  
  // Calcular meses
  while (remainingDays >= 28) {
    final int daysInMonth = _daysInMonth(tempDate.year, tempDate.month);
    if (remainingDays >= daysInMonth) {
      months++;
      remainingDays -= daysInMonth;
      
      // Avanzar al siguiente mes
      if (tempDate.month == 12) {
        tempDate = DateTime(tempDate.year + 1, 1, tempDate.day);
      } else {
        // Ajustar para meses con menos días que el día actual
        final int maxDays = _daysInMonth(tempDate.year, tempDate.month + 1);
        final int newDay = tempDate.day > maxDays ? maxDays : tempDate.day;
        tempDate = DateTime(tempDate.year, tempDate.month + 1, newDay);
      }
    } else {
      break;
    }
  }
  
  // Formateo en español con pluralización correcta
  if (years > 0) {
    if (months > 0) {
      return '$years ${years == 1 ? 'año' : 'años'}, $months ${months == 1 ? 'mes' : 'meses'}';
    } else {
      return '$years ${years == 1 ? 'año' : 'años'}';
    }
  } else if (months > 0) {
    return '$months ${months == 1 ? 'mes' : 'meses'}';
  } else {
    return '$remainingDays ${remainingDays == 1 ? 'día' : 'días'}';
  }
}
  
  /// Determina los días en un mes específico (considera años bisiestos)
  int _daysInMonth(int year, int month) {
    const List<int> daysPerMonth = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    
    // Ajuste para febrero en años bisiestos
    if (month == 2 && _isLeapYear(year)) {
      return 29;
    }
    
    return daysPerMonth[month];
  }
  
  /// Verifica si un año es bisiesto
  bool _isLeapYear(int year) {
    return year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
  }

  /// Muestra un mensaje de éxito
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Muestra un mensaje de error
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  /// Widget para mostrar campos no editables
  Widget _buildInfoField(
    String label, 
    String value, 
    IconData icon, {
    bool isEditable = false,
    TextEditingController? controller,
  }) {
    if (isEditable && controller != null) {
      // Campo editable con TextField
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: Colors.grey),
                SizedBox(width: _smallSpacing),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: _smallSpacing / 2),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(width: 1),
                ),
                isDense: true,
              ),
            ),
          ],
        ),
      );
    } else {
      // Campo no editable (solo muestra información)
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey),
            SizedBox(width: _smallSpacing),
            Text(
              '$label: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }
  }
  
  /// Muestra la pantalla de ajustes
  void _showSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AjustesScreen(
          userId: _viewModel.userId,
        ),
      ),
    );
  }
  
  /// Muestra diálogo de confirmación para eliminar mascota
  void _showDeletePetDialog(String petUID, String petName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar mascota'),
        content: Text('¿Estás seguro que deseas eliminar a $petName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePet(petUID, petName);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
  
  /// Ejecuta la eliminación de una mascota
  void _deletePet(String petUID, String petName) {
    try {
      _viewModel.deleteCurrentPet();
      _showSuccessMessage('$petName ha sido eliminado');
    } catch (error) {
      _showErrorMessage('Error: $error');
    }
  }
  
  /// Construye la sección de información del usuario con biografía integrada
  Widget _buildUserInfoSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de sección con botón de ajustes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Datos del Usuario',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: theme.colorScheme.primary),
              onPressed: _showSettings,
              tooltip: 'Ajustes',
            ),
          ],
        ),
        SizedBox(height: 0),
        
        // Tarjeta con foto e información básica
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: EdgeInsets.all(_cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selector de foto de perfil usando consumer
                    Consumer<PerfilViewModel>(
                      builder: (context, viewModel, _) => SizedBox(
                        width: _profileImageSize,
                        height: _profileImageSize,
                        child: SelectorFotos(
                          imagenes: [viewModel.userImage],
                          maxPhotos: 1,
                          onImagesUpdated: _handleUserPhotoUpdate,
                          entidadId: viewModel.userId,
                          apiService: viewModel.apiService,
                          tipo: 'usuario',
                          userUID: viewModel.userId,
                        ),
                      ),
                    ),
                    SizedBox(width: _itemSpacing),
                    
                    // Información básica del usuario usando consumer
                    Expanded(
                      child: Consumer<PerfilViewModel>(
                        builder: (context, viewModel, _) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              viewModel.userNameController.text,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: _smallSpacing),
                            _buildInfoField(
                              'Cumpleaños', 
                              _formatBirthday(viewModel.userBirthDate),
                              Icons.cake_outlined
                            ),
                            _buildInfoField('Edad', viewModel.userAgeController.text, Icons.access_time),
                            _buildInfoField('Sexo', viewModel.userSexController.text, Icons.person),                            
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Biografía del usuario con icono de edición
                SizedBox(height: 0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.description, size: 16, color: Colors.grey),
                        SizedBox(width: _smallSpacing),
                        const Text(
                          'Biografía',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    // Botón de editar/guardar biografía
                    IconButton(
                      icon: Icon(
                        _isEditingUserBio ? Icons.save : Icons.edit,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          _isEditingUserBio = !_isEditingUserBio;
                          
                          // Si estamos guardando (al presionar el botón save)
                          if (!_isEditingUserBio) {
                            // Llamar al método para actualizar la biografía del usuario
                            _viewModel.updateUserBio(_viewModel.userBioController.text).then((_) {
                              _showSuccessMessage('Biografía usuario actualizada');
                            }).catchError((error) {
                              _showErrorMessage('Error al actualizar la biografía: $error');
                            });
                          }
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 0),
                Consumer<PerfilViewModel>(
                  builder: (context, viewModel, _) => _isEditingUserBio 
                    // Modo edición: TextField
                    ? TextField(
                        controller: viewModel.userBioController,
                        decoration: InputDecoration(
                          hintText: 'Cuéntanos algo sobre ti...',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(width: 1),
                          ),
                          isDense: true,
                        ),
                        maxLines: 3,
                      )
                    // Modo visualización: Container con texto
                    : Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          viewModel.userBioController.text.isEmpty 
                              ? 'Cuéntanos algo sobre ti...' 
                              : viewModel.userBioController.text,
                          style: TextStyle(
                            color: viewModel.userBioController.text.isEmpty 
                                ? Colors.grey 
                                : theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  /// Maneja la actualización de foto de perfil del usuario
  Future<void> _handleUserPhotoUpdate(List<String> updatedImages) async {
    if (updatedImages.isEmpty) return;
    
    try {
      await _viewModel.updateUserPhoto();
      _showSuccessMessage('Imagen actualizada correctamente');
    } catch (e) {
      _showErrorMessage('Error al actualizar la imagen: $e');
    }
  }

  /// Construye la sección de lista de mascotas con círculos horizontales
  Widget _buildPetsListSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mis Mascotas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(height: _itemSpacing),
        
        Consumer<PerfilViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return _buildPetsCirclesList(viewModel);
            }
          },
        ),
      ],
    );
  }
  
 /// Muestra el formulario para añadir una nueva mascota
void _addNewPet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.9, // Ocupa el 90% de la pantalla
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: CreatePetForm(
        viewModel: _viewModel,
        onSuccess: () {
          Navigator.pop(context); // Cierra el modal
          _showSuccessMessage('Mascota creada con éxito');
          // Recargar datos para ver la nueva mascota
          _viewModel.loadAllData();
        },
        onCancel: () {
          Navigator.pop(context); // Solo cierra el modal
        },
      ),
    ),
  );
}
  
  /// Construye la lista horizontal de círculos de mascotas
Widget _buildPetsCirclesList(PerfilViewModel viewModel) {
  // Aumentamos la altura para dar más espacio
  return SizedBox(
    height: _petAvatarSize + 40, // Aumentado de 30 a 40 para más espacio vertical
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        // Círculos para cada mascota
        ...List.generate(viewModel.pets.length, (index) {
          final pet = viewModel.pets[index];
          final petImageUrl = pet.petImage1.isNotEmpty 
              ? pet.petImage1 
              : 'https://via.placeholder.com/150/cccccc/FFFFFF/?text=Mascota';
              
          final bool isSelected = index == viewModel.selectedPetIndex;
              
          return GestureDetector(
            onTap: () => viewModel.changePet(index),
            onLongPress: () => _showPetOptionsMenu(pet, index),
            child: Container(
              width: _petAvatarSize,
              margin: EdgeInsets.only(right: _itemSpacing),
              child: Column(
                children: [
                  // Avatar circular con indicador de selección
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: _petAvatarSize / 2,
                        backgroundImage: NetworkImage(petImageUrl),
                        onBackgroundImageError: (exception, stackTrace) {
                          print('Error cargando imagen de mascota: $exception');
                        },
                      ),
                      if (isSelected)
                        Container(
                          width: _petAvatarSize + 6,
                          height: _petAvatarSize + 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 3,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: _smallSpacing),
                  // Nombre de la mascota - Reducimos el tamaño del texto para evitar overflow
                  Container(
                    width: _petAvatarSize,
                    child: Text(
                      pet.name,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      maxLines: 1, // Forzamos a una sola línea
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Theme.of(context).colorScheme.primary : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        
        // Círculo de añadir mascota
        GestureDetector(
          onTap: _addNewPet,
          child: Container(
            width: _petAvatarSize,
            child: Column(
              children: [
                Container(
                  width: _petAvatarSize,
                  height: _petAvatarSize,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: _smallSpacing),
                const Text(
                  'Añadir',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

  
  /// Muestra un menú emergente con opciones para una mascota
  void _showPetOptionsMenu(PetModel pet, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Editar'),
            onTap: () {
              Navigator.pop(context);
              _editPet(index, pet.name);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showDeletePetDialog(pet.petUID, pet.name);
            },
          ),
        ],
      ),
    );
  }
  
  /// Cambia a editar una mascota específica
  void _editPet(int index, String petName) {
    _viewModel.changePet(index);
    _showSuccessMessage('Editando información de $petName');
  }
  
  /// Construye la sección de edición de mascota seleccionada
  Widget _buildPetEditSection(ThemeData theme) {
  return Consumer<PerfilViewModel>(
    builder: (context, viewModel, _) {
      if (!viewModel.hasPets || viewModel.currentPet == null) {
        return const SizedBox.shrink();
      }
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con título y botón de eliminar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Editar ${viewModel.nameController.text}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 28,
                ),
                onPressed: () => _showDeletePetDialog(
                  viewModel.currentPet!.petUID,
                  viewModel.nameController.text,
                ),
                tooltip: 'Eliminar mascota',
              ),
            ],
          ),
          SizedBox(height: 0),
          
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: EdgeInsets.all(_cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección de fotos
                  const Text(
                    'Fotos',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: _smallSpacing),
                  
                  SelectorFotos(
                    imagenes: viewModel.petImages,
                    onImagesUpdated: _handlePetImagesUpdate,
                    maxPhotos: 3,
                    entidadId: viewModel.currentPet?.petUID ?? '',
                    apiService: viewModel.apiService,
                    tipo: 'mascota',
                    userUID: viewModel.userId,
                  ),
                  SizedBox(height: _itemSpacing),
                  
                  // SECCIÓN: Información de la mascota
                  const Text(
                    'Información de la mascota',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: _smallSpacing),
                  
                  // Campo no editable del cumpleaños con formato dd-mm-aaaa
                  _buildInfoField(
                    'Cumpleaños', 
                    _formatBirthday(viewModel.currentPet?.birthDate),
                    Icons.cake,
                  ),
                  
                  // Campo no editable de la edad calculada
                  _buildInfoField(
                    'Edad', 
                    _calculateAge(viewModel.currentPet?.birthDate),
                    Icons.access_time,
                  ),
                  
                  // Campo no editable de la especie
                  _buildInfoField(
                    'Especie', 
                    viewModel.currentPet?.species ?? 'No especificada',
                    Icons.category,
                  ),
                  
                  // AÑADIDO: Campo no editable del sexo de la mascota
                  _buildInfoField(
                    'Sexo', 
                    viewModel.currentPet?.sex ?? 'No especificado',
                    Icons.pets,
                  ),
                  
                  // Sección de biografía con icono de edición
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.description, size: 16, color: Colors.grey),
                          SizedBox(width: _smallSpacing),
                          const Text(
                            'Biografía',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      // Botón de editar/guardar biografía
                      IconButton(
                        icon: Icon(
                          _isEditingPetBio ? Icons.save : Icons.edit,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          setState(() {
                            _isEditingPetBio = !_isEditingPetBio;
                            
                            // Si estamos guardando (al presionar el botón save)
                            if (!_isEditingPetBio) {
                              // Llamar al método para actualizar la biografía de la mascota
                              _viewModel.updateCurrentPetBio(_viewModel.bioController.text).then((_) {
                                _showSuccessMessage('Biografía de mascota actualizada');
                              }).catchError((error) {
                                _showErrorMessage('Error al actualizar la biografía: $error');
                              });
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 0),
                  
                  // Campo de biografía condicional (editable o no)
                  _isEditingPetBio
                    // Modo edición: TextField
                    ? TextField(
                        controller: viewModel.bioController,
                        decoration: InputDecoration(
                          hintText: 'Describe a tu mascota...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLines: 3,
                      )
                    // Modo visualización: Container con texto
                    : Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          viewModel.bioController.text.isEmpty
                              ? 'Describe a tu mascota...'
                              : viewModel.bioController.text,
                          style: TextStyle(
                            color: viewModel.bioController.text.isEmpty
                                ? Colors.grey
                                : theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}
  
  /// Maneja la actualización de imágenes de mascota
  Future<void> _handlePetImagesUpdate(List<String> updatedImages) async {
    try {
      await _viewModel.updatePetImages(updatedImages);
      _showSuccessMessage('Imágenes actualizadas. No olvides guardar los cambios.');
    } catch (e) {
      _showErrorMessage('Error al actualizar imágenes: $e');
    }
  }
  
  /// Guarda todos los cambios
  Future<void> _saveAllChanges() async {
    try {
      await _viewModel.saveAllData();
      _showSuccessMessage('Cambios guardados correctamente');
    } catch (error) {
      _showErrorMessage('Error al guardar datos: $error');
    }
  }
  
  @override
Widget build(BuildContext context) {
  // Obtiene el tema actual y la referencia al ThemeProvider
  final themeProvider = Provider.of<ThemeProvider>(context);
  final isDarkMode = themeProvider.isDarkMode;
  final theme = isDarkMode ? themeProvider.darkTheme : themeProvider.lightTheme;
  
  // Envolvemos todo en un ChangeNotifierProvider para que el ViewModel esté disponible
  return ChangeNotifierProvider.value(
    value: _viewModel,
    child: Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Mi Perfil',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),          
          actions: [
            // Botón para guardar todos los cambios
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveAllChanges,
              tooltip: 'Guardar cambios',
            ),
          ],
        ),
        body: SafeArea(
          child: Consumer<PerfilViewModel>(
            builder: (context, viewModel, _) {
              if (viewModel.isInitialLoading) {
                // Mostrar loading mientras se cargan datos inicialmente
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Cargando perfil...'),
                    ],
                  ),
                );
              }
              
              // Contenido principal con scroll
              return RefreshIndicator(
                onRefresh: viewModel.loadAllData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sección de información del usuario
                      _buildUserInfoSection(theme),
                      
                      SizedBox(height: _sectionSpacing),
                      
                      // Sección lista de mascotas (círculos)
                      _buildPetsListSection(theme),
                      
                      SizedBox(height: _sectionSpacing),
                      
                      // Sección de edición de mascota seleccionada
                      _buildPetEditSection(theme),
                      
                      // Espacio al final para asegurar que todo sea accesible
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}
}