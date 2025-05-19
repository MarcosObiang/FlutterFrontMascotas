import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mascotas_citas/Modules/ProfileModule/ViewModels/perfil_view_model.dart';
import 'package:mascotas_citas/Resources/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class CreatePetForm extends StatefulWidget {
  final PerfilViewModel viewModel;
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const CreatePetForm({
    Key? key,
    required this.viewModel,
    required this.onSuccess,
    required this.onCancel,
  }) : super(key: key);

  @override
  _CreatePetFormState createState() => _CreatePetFormState();
}

class _CreatePetFormState extends State<CreatePetForm> {
  // Controladores para los campos del formulario
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  // Variables de estado
  String _selectedSpecies = 'Perro';
  String _selectedSex = 'Macho';
  DateTime? _selectedBirthDate;
  
  // Manejo de imágenes
  final ImagePicker _picker = ImagePicker();
  File? _petImage1;
  File? _petImage2;
  File? _petImage3;
  
  // Lista de especies disponibles
  final List<String> _speciesList = [
    'Perro',
    'Gato',
    'Ave',
    'Conejo',
    'Hámster',
    'Pez',
    'Reptil',
    'Otro'
  ];
  
  bool _isLoading = false;
  String? _errorMessage;

  // Validación del formulario
  bool get _isFormValid => 
      _nameController.text.isNotEmpty &&
      _selectedBirthDate != null &&
      _petImage1 != null;

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // Seleccionar fecha de nacimiento
  Future<void> _selectBirthDate() async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = _selectedBirthDate ?? DateTime(now.year - 1, now.month, now.day);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: themeProvider.isDarkMode 
              ? themeProvider.darkTheme 
              : themeProvider.lightTheme,
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }
  
  // Formato de la fecha para mostrar
  String get _formattedBirthDate {
    if (_selectedBirthDate == null) {
      return 'No seleccionada';
    }
    
    return DateFormat('dd-MM-yyyy').format(_selectedBirthDate!);
  }
  
  // Seleccionar imagen de galería
  Future<void> _pickImage(int imageNumber) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          switch (imageNumber) {
            case 1:
              _petImage1 = File(pickedFile.path);
              break;
            case 2:
              _petImage2 = File(pickedFile.path);
              break;
            case 3:
              _petImage3 = File(pickedFile.path);
              break;
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al seleccionar imagen: $e';
      });
    }
  }
  
  // Enviar formulario
  Future<void> _submitForm() async {
    if (!_isFormValid) {
      setState(() {
        _errorMessage = 'Por favor completa todos los campos obligatorios y añade al menos una foto';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final birthDateStr = DateFormat('yyyy-MM-dd').format(_selectedBirthDate!);
      
      await widget.viewModel.addNewPet(
        name: _nameController.text,
        species: _selectedSpecies,
        sex: _selectedSex,
        birthDate: birthDateStr,
        bio: _bioController.text,
        petImage1: _petImage1!,
        petImage2: _petImage2,
        petImage3: _petImage3,
      );
      
      // Mostrar mensaje de éxito antes de cerrar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('¡Mascota creada con éxito!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Pequeña pausa para que el usuario vea el mensaje antes de cerrar
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Llamar al callback de éxito que cerrará el formulario
        widget.onSuccess();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al crear mascota: $e';
        _isLoading = false;
      });
    }
  }
  
  // Widget para mostrar imágenes seleccionadas o placeholder
  Widget _buildImageSelector(int imageNumber, File? image) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorScheme = themeProvider.isDarkMode 
        ? themeProvider.darkTheme.colorScheme 
        : themeProvider.lightTheme.colorScheme;
    
    return GestureDetector(
      onTap: () => _pickImage(imageNumber),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: imageNumber == 1 && image == null
                ? colorScheme.error
                : colorScheme.outline,
            width: imageNumber == 1 && image == null ? 2 : 1,
          ),
          image: image != null
              ? DecorationImage(
                  image: FileImage(image),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 32,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    imageNumber == 1 ? 'Principal*' : 'Opcional',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the ThemeProvider to access theme data
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.isDarkMode 
        ? themeProvider.darkTheme 
        : themeProvider.lightTheme;
    final colorScheme = theme.colorScheme;
    
    // Apply the theme to the entire form using Theme widget
    return Theme(
      data: theme,
      child: Container(
        color: colorScheme.surface,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título del formulario
                        Text(
                          'Añadir nueva mascota',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Nombre de la mascota (obligatorio)
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Nombre*',
                            hintText: 'Nombre de tu mascota',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: colorScheme.outline),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: colorScheme.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: colorScheme.primary, width: 2),
                            ),
                            prefixIcon: Icon(Icons.pets, color: colorScheme.onSurfaceVariant),
                            labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
                            fillColor: colorScheme.surface,
                            filled: true,
                          ),
                          style: TextStyle(color: colorScheme.onSurface),
                        ),
                        const SizedBox(height: 16),
                        
                        // Selector de especie
                        DropdownButtonFormField<String>(
                          value: _selectedSpecies,
                          decoration: InputDecoration(
                            labelText: 'Especie*',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: colorScheme.outline),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: colorScheme.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: colorScheme.primary, width: 2),
                            ),
                            prefixIcon: Icon(Icons.category, color: colorScheme.onSurfaceVariant),
                            labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                            fillColor: colorScheme.surface,
                            filled: true,
                          ),
                          dropdownColor: colorScheme.surface,
                          style: TextStyle(color: colorScheme.onSurface),
                          icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
                          items: _speciesList.map((String species) {
                            return DropdownMenuItem<String>(
                              value: species,
                              child: Text(species),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedSpecies = newValue;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Sexo de la mascota
                        DropdownButtonFormField<String>(
                          value: _selectedSex,
                          decoration: InputDecoration(
                            labelText: 'Sexo*',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: colorScheme.outline),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: colorScheme.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: colorScheme.primary, width: 2),
                            ),
                            prefixIcon: Icon(Icons.transgender, color: colorScheme.onSurfaceVariant),
                            labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                            fillColor: colorScheme.surface,
                            filled: true,
                          ),
                          dropdownColor: colorScheme.surface,
                          style: TextStyle(color: colorScheme.onSurface),
                          icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
                          items: const [
                            DropdownMenuItem(value: 'Macho', child: Text('Macho')),
                            DropdownMenuItem(value: 'Hembra', child: Text('Hembra')),
                          ],
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedSex = newValue;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Fecha de nacimiento
                        InkWell(
                          onTap: _selectBirthDate,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Fecha de nacimiento*',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: colorScheme.outline),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: _selectedBirthDate == null 
                                    ? colorScheme.error 
                                    : colorScheme.outline),
                              ),
                              prefixIcon: Icon(Icons.cake, color: colorScheme.onSurfaceVariant),
                              errorText: _selectedBirthDate == null ? 'Requerido' : null,
                              labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                              fillColor: colorScheme.surface,
                              filled: true,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formattedBirthDate,
                                  style: TextStyle(color: colorScheme.onSurface),
                                ),
                                Icon(Icons.calendar_today, color: colorScheme.onSurfaceVariant),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Biografía (opcional)
                        TextField(
                          controller: _bioController,
                          decoration: InputDecoration(
                            labelText: 'Biografía',
                            hintText: 'Cuéntanos sobre tu mascota...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: colorScheme.outline),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: colorScheme.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: colorScheme.primary, width: 2),
                            ),
                            prefixIcon: Icon(Icons.description, color: colorScheme.onSurfaceVariant),
                            labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
                            fillColor: colorScheme.surface,
                            filled: true,
                          ),
                          style: TextStyle(color: colorScheme.onSurface),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),
                        
                        // Sección de fotos
                        Text(
                          'Fotos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'La primera foto es obligatoria',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Selectores de imágenes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildImageSelector(1, _petImage1),
                            _buildImageSelector(2, _petImage2),
                            _buildImageSelector(3, _petImage3),
                          ],
                        ),
                        
                        // Mensaje de error
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: colorScheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                
                // Botones de acción
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isLoading ? null : widget.onCancel,
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(color: colorScheme.primary),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          disabledBackgroundColor: colorScheme.onSurfaceVariant.withOpacity(0.12),
                          disabledForegroundColor: colorScheme.onSurfaceVariant.withOpacity(0.38),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                                ),
                              )
                            : const Text('Guardar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}