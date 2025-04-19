// screens/social_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:timeago/timeago.dart' as timeago;

// Modelo de Publicación actualizado según tu requisito
class Publicacion {
  final String id;
  final String usuarioId;
  final String nombreUsuario;
  final String avatarUrl;
  final String contenido;
  final String? imagenUrl;
  final DateTime fechaPublicacion;
  final List comentarios;
  final int likes;
  bool usuarioDioLike;

  Publicacion({
    required this.id,
    required this.usuarioId,
    required this.nombreUsuario,
    required this.avatarUrl,
    required this.contenido,
    this.imagenUrl,
    required this.fechaPublicacion,
    List? comentarios,
    this.likes = 0,
    this.usuarioDioLike = false,
  }) : this.comentarios = comentarios ?? [];
}

class SocialScreen extends StatefulWidget {
  @override
  _SocialScreenState createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  final TextEditingController _postController = TextEditingController();
  bool _isComposing = false;
  File? _selectedImage;
  bool _isUploading = false;

  // Datos simulados del usuario actual
  final String miUsuarioId = 'miUsuario';
  final String nombreUsuario = 'Luna';
  final String avatarUrl = 'https://images.unsplash.com/photo-1543466835-00a7907e9de1';
  
  // Lista de publicaciones simuladas con la nueva estructura
  List<Publicacion> _publicaciones = [
    Publicacion(
      id: 'p1',
      usuarioId: 'user1',
      nombreUsuario: 'Max',
      avatarUrl: 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e',
      contenido: 'Hoy es un día perfecto para jugar en el parque',
      imagenUrl: 'https://images.unsplash.com/photo-1534361960057-19889db9621e',
      fechaPublicacion: DateTime.now().subtract(Duration(hours: 2)),
      likes: 8,
      comentarios: [
        {'usuario': 'Carlos', 'texto': '¡Qué lindo!'},
        {'usuario': 'Ana', 'texto': 'Me encanta verlo jugar'},
      ],
    ),
    Publicacion(
      id: 'p2',
      usuarioId: 'user2',
      nombreUsuario: 'Rocky',
      avatarUrl: 'https://images.unsplash.com/photo-1587300003388-59208cc962cb',
      contenido: 'Mi primera vez en la playa, ¡increíble!',
      imagenUrl: 'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1',
      fechaPublicacion: DateTime.now().subtract(Duration(days: 1)),
      likes: 15,
      comentarios: [
        {'usuario': 'María', 'texto': '¡Qué divertido!'},
        {'usuario': 'Juan', 'texto': 'La playa es genial para los perros'},
      ],
    ),
    Publicacion(
      id: 'p3',
      usuarioId: 'user3',
      nombreUsuario: 'Bella',
      avatarUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba',
      contenido: 'Aprendiendo nuevos trucos',
      imagenUrl: null,
      fechaPublicacion: DateTime.now().subtract(Duration(days: 2)),
      likes: 12,
      comentarios: [
        {'usuario': 'Pedro', 'texto': '¡Impresionante!'},
      ],
    ),
  ];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Configurar timeago para español
    timeago.setLocaleMessages('es', timeago.EsMessages());
  }

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
          _isComposing = true; // Activamos el botón de publicar
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

  // Método para dar like a una publicación
  void _darLike(String publicacionId) {
    setState(() {
      final index = _publicaciones.indexWhere((p) => p.id == publicacionId);
      if (index != -1) {
        final publicacion = _publicaciones[index];
        // Toggle del like
        if (publicacion.usuarioDioLike) {
          _publicaciones[index] = Publicacion(
            id: publicacion.id,
            usuarioId: publicacion.usuarioId,
            nombreUsuario: publicacion.nombreUsuario,
            avatarUrl: publicacion.avatarUrl,
            contenido: publicacion.contenido,
            imagenUrl: publicacion.imagenUrl,
            fechaPublicacion: publicacion.fechaPublicacion,
            comentarios: publicacion.comentarios,
            likes: publicacion.likes - 1,
            usuarioDioLike: false,
          );
        } else {
          _publicaciones[index] = Publicacion(
            id: publicacion.id,
            usuarioId: publicacion.usuarioId,
            nombreUsuario: publicacion.nombreUsuario,
            avatarUrl: publicacion.avatarUrl,
            contenido: publicacion.contenido,
            imagenUrl: publicacion.imagenUrl,
            fechaPublicacion: publicacion.fechaPublicacion,
            comentarios: publicacion.comentarios,
            likes: publicacion.likes + 1,
            usuarioDioLike: true,
          );
        }
      }
    });
  }

  // Método para mostrar comentarios
  void _mostrarComentarios(Publicacion publicacion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Comentarios (${publicacion.comentarios.length})',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: publicacion.comentarios.length,
                itemBuilder: (context, index) {
                  final comentario = publicacion.comentarios[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          child: Icon(Icons.person, color: Colors.white),
                          radius: 16,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                comentario['usuario'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(comentario['texto']),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 
                  16 + MediaQuery.of(context).viewInsets.bottom),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Añadir un comentario...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send, color: Colors.pink),
                    onPressed: () {
                      // Aquí iría la lógica para añadir un comentario
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para publicar
  Future<void> _publicar() async {
    if (_postController.text.isEmpty && _selectedImage == null) return;
    
    setState(() {
      _isUploading = true;
    });
    
    try {
      // Simulamos la subida con un pequeño retraso
      await Future.delayed(Duration(seconds: 1));
      
      String? imageUrl;
      if (_selectedImage != null) {
        // En un entorno real, aquí subirías la imagen y obtendrías la URL
        // Para este ejemplo, simplemente usamos la ruta local
        imageUrl = _selectedImage!.path;
      }
      
      // Crear nueva publicación con la estructura actualizada
      final nuevaPublicacion = Publicacion(
        id: 'p${_publicaciones.length + 1}',
        usuarioId: miUsuarioId,
        nombreUsuario: nombreUsuario,
        avatarUrl: avatarUrl,
        contenido: _postController.text,
        imagenUrl: imageUrl,
        fechaPublicacion: DateTime.now(),
        likes: 0,
        usuarioDioLike: false,
      );
      
      // Agregar a la lista de publicaciones
      setState(() {
        _publicaciones.insert(0, nuevaPublicacion);
        _selectedImage = null;
        _isComposing = false;
        _isUploading = false;
      });
      
      _postController.clear();
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
              color: Colors.white,
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
                      backgroundImage: NetworkImage(avatarUrl),
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
                            onPressed: _isComposing ? _publicar : null,
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
            child: _publicaciones.isEmpty
                ? Center(child: Text('¡Aún no hay publicaciones! Sé el primero en compartir.'))
                : RefreshIndicator(
                    onRefresh: () async {
                      // En una implementación real, aquí cargaríamos nuevas publicaciones
                      await Future.delayed(Duration(seconds: 1));
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.all(8.0),
                      itemCount: _publicaciones.length,
                      itemBuilder: (context, index) {
                        return _buildPublicacionCard(_publicaciones[index]);
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

  // Widget para mostrar una publicación (basado en PublicacionCard)
  Widget _buildPublicacionCard(Publicacion publicacion) {
    final fechaRelativa = timeago.format(publicacion.fechaPublicacion, locale: 'es');

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado de la publicación
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(publicacion.avatarUrl),
                  radius: 22,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        publicacion.nombreUsuario,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        fechaRelativa,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Contenido de la publicación
            if (publicacion.contenido.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  publicacion.contenido,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            
            // Imagen de la publicación (si existe)
            if (publicacion.imagenUrl != null)
              Padding(
                padding: EdgeInsets.only(top: publicacion.contenido.isEmpty ? 12 : 0, bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildImageWidget(publicacion.imagenUrl!),
                ),
              ),
            
            // Contadores y acciones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Contador de likes
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 18,
                      color: Colors.pink,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${publicacion.likes}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                
                // Contador de comentarios
                InkWell(
                  onTap: () => _mostrarComentarios(publicacion),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 18,
                        color: Colors.grey.shade700,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${publicacion.comentarios.length}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            Divider(height: 24),
            
            // Botones de acciones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Botón de Like
                InkWell(
                  onTap: () => _darLike(publicacion.id),
                  child: Row(
                    children: [
                      Icon(
                        publicacion.usuarioDioLike ? Icons.favorite : Icons.favorite_border,
                        color: publicacion.usuarioDioLike ? Colors.pink : Colors.grey.shade700,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Me gusta',
                        style: TextStyle(
                          color: publicacion.usuarioDioLike ? Colors.pink : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Botón de Comentar
                InkWell(
                  onTap: () => _mostrarComentarios(publicacion),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.grey.shade700,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Comentar',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Método para determinar si mostrar una imagen local o de red
  Widget _buildImageWidget(String imagePath) {
    if (imagePath.startsWith('http')) {
      // Es una URL de imagen en línea
      return Image.network(
        imagePath,
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 250,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 250,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: Center(
              child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
            ),
          );
        },
      );
    } else {
      // Es una ruta de archivo local
      return Image.file(
        File(imagePath),
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 250,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: Center(
              child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
            ),
          );
        },
      );
    }
  }
}