// screens/social_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../State/social_provider.dart';
import '../../../Resources/Widgets/publicacion_card.dart';
import '../../HomeModule/State/mascota_provider.dart';


class SocialScreen extends StatefulWidget {
  @override
  _SocialScreenState createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  final TextEditingController _postController = TextEditingController();
  bool _isComposing = false;
  File? _selectedImage;
  bool _isUploading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  // Método para seleccionar una imagen
  Future<void> _seleccionarImagen(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  // Método para mostrar el modal de selección de imagen
  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Galería'),
                onTap: () {
                  Navigator.of(context).pop();
                  _seleccionarImagen(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Cámara'),
                onTap: () {
                  Navigator.of(context).pop();
                  _seleccionarImagen(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Método para publicar con o sin imagen
  Future<void> _publicar(SocialProvider socialProvider, MascotaProvider mascotaProvider) async {
    if (_postController.text.isEmpty && _selectedImage == null) return;
    
    setState(() {
      _isUploading = true;
    });
    
    try {
      // En una implementación real, aquí subirías la imagen a un servidor
      // y obtendrías una URL para almacenar en la publicación
      String? imageUrl;
      
      if (_selectedImage != null) {
        // Simulamos la subida con un pequeño retraso
        await Future.delayed(Duration(seconds: 1));
        
        // En un entorno real, aquí tendrías la URL de la imagen subida
        // Para este ejemplo, simplemente usamos la ruta local
        imageUrl = _selectedImage!.path;
        
        // En una app real, podrías usar Firebase Storage u otro servicio:
        // final ref = FirebaseStorage.instance.ref().child('publicaciones/${DateTime.now().millisecondsSinceEpoch}.jpg');
        // await ref.putFile(_selectedImage!);
        // imageUrl = await ref.getDownloadURL();
      }
      
      socialProvider.agregarPublicacion(
        'miUsuario',
        mascotaProvider.miMascota?.nombre ?? 'Mi Mascota',
        mascotaProvider.miMascota?.fotoPerfil ?? 'https://via.placeholder.com/150',
        _postController.text,
        imageUrl,
      );
      
      // Limpiamos el formulario
      _postController.clear();
      setState(() {
        _selectedImage = null;
        _isComposing = false;
        _isUploading = false;
      });
      
      FocusScope.of(context).unfocus();
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al publicar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final socialProvider = Provider.of<SocialProvider>(context);
    final mascotaProvider = Provider.of<MascotaProvider>(context);
    final publicaciones = socialProvider.publicaciones;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(242, 217, 208, 1),
        title: Text('Feed Social', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.add_photo_alternate),
            onPressed: _mostrarOpcionesImagen,
          ),
        ],
      ),
      backgroundColor: Color.fromRGBO(242, 217, 208, 1),
      body: Column(
        children: [
          // Área de composición
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Color.fromRGBO(242, 217, 208, 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                )
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        mascotaProvider.miMascota?.fotoPerfil ?? 'https://via.placeholder.com/150',
                      ),
                      radius: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _postController,
                        decoration: InputDecoration(
                          hintText: '¿Qué está haciendo tu mascota?',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        ),
                        onChanged: (text) {
                          setState(() {
                            _isComposing = text.isNotEmpty || _selectedImage != null;
                          });
                        },
                        maxLines: null,
                      ),
                    ),
                    SizedBox(width: 10),
                    _isUploading 
                        ? CircularProgressIndicator(color: Colors.pink)
                        : IconButton(
                            icon: Icon(Icons.send),
                            color: _isComposing ? Colors.pink : Colors.grey,
                            onPressed: _isComposing
                                ? () => _publicar(socialProvider, mascotaProvider)
                                : null,
                          ),
                  ],
                ),
                
                // Vista previa de la imagen seleccionada
                if (_selectedImage != null)
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImage = null;
                                _isComposing = _postController.text.isNotEmpty;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              padding: EdgeInsets.all(5),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // Lista de publicaciones
          Expanded(
            child: publicaciones.isEmpty
                ? Center(child: Text('¡Aún no hay publicaciones! Sé el primero en compartir.'))
                : RefreshIndicator(
                    onRefresh: () async {
                      // En una implementación real, aquí cargaríamos nuevas publicaciones
                      await Future.delayed(Duration(seconds: 1));
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.all(8.0),
                      itemCount: publicaciones.length,
                      itemBuilder: (context, index) {
                        return PublicacionCard(publicacion: publicaciones[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarOpcionesImagen,
        backgroundColor: Colors.pink,
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}