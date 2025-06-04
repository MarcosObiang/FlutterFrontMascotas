import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as _apiService;
import 'package:image_picker/image_picker.dart';
import 'package:mascotas_citas/Modules/ProfileModule/ViewModels/perfil_view_model.dart';
import 'package:mascotas_citas/Modules/SocialModule/models/CommentRepliesModel.dart';
import 'package:mascotas_citas/Modules/SocialModule/models/PostLikesModel.dart';
import 'package:mascotas_citas/dependencies/injector.dart';
import 'package:mascotas_citas/services/ApiServiceRD.dart';
import 'package:mascotas_citas/services/auth/AuthSesionDataService.dart';
import 'package:mascotas_citas/services/platform/storage/SecureStorage.dart';
import 'dart:io';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import '../State/social_provider.dart';
import '../models/SocialModel.dart';
import '../models/CommentsModel.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  _SocialScreenState createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  final TextEditingController _postController = TextEditingController();
  bool _isComposing = false;
  File? _selectedImage;
  bool _isUploading = false;
  late PerfilViewModel _viewModel;









  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('es', timeago.EsMessages());
    Provider.of<SocialProvider>(context, listen: false).cargarPublicaciones();
    
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
    _postController.dispose();
    _viewModel.dispose();
    super.dispose();
  }
  

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
          _isComposing = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

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

  Future<void> _publicar() async {
    final viewModel = Provider.of<PerfilViewModel>(context, listen: false);
                
      String miUsuarioId = viewModel.userId;
    if (_postController.text.isEmpty && _selectedImage == null) return;
    setState(() => _isUploading = true);

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = _selectedImage!.path;
      }

      await Provider.of<SocialProvider>(context, listen: false).crearPublicacion(
  {
    'userUID': miUsuarioId,
    'description': _postController.text,
    // otros campos...
  },
  postImage1: _selectedImage, // <-- Aquí pasas el File de la imagen
);

      setState(() {
        _selectedImage = null;
        _isComposing = false;
        _isUploading = false;
      });
      _postController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al publicar: $e')),
      );
    }
  }

  void _darLike(SocialModel publicacion) async {
    final viewModel = Provider.of<PerfilViewModel>(context, listen: false);
                
      String miUsuarioId = viewModel.userId;
    final likeado = await Provider.of<SocialProvider>(context, listen: false)
        .estaLikeado({'postUID': publicacion.postUID, 'userUID': miUsuarioId});
    if (likeado) {
      await Provider.of<SocialProvider>(context, listen: false)
          .quitarLike({'postUID': publicacion.postUID, 'userUID': miUsuarioId});
    } else {
      await Provider.of<SocialProvider>(context, listen: false)
          .darLike({'postUID': publicacion.postUID, 'userUID': miUsuarioId});
    }
    // No necesitas setState si tu provider hace notifyListeners y tu UI depende de él
  }

  void _mostrarComentarios(SocialModel publicacion) async {
    final viewModel = Provider.of<PerfilViewModel>(context, listen: false);
                
      String miUsuarioId = viewModel.userId;
      String nombreUsuario = viewModel.userNameController.text;
      String avatarUrl = viewModel.userImage;
    await Provider.of<SocialProvider>(context, listen: false).cargarComentarios(publicacion.postUID);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final comentarios = Provider.of<SocialProvider>(context).comentarios;
        final replies = Provider.of<SocialProvider>(context).replies;
        final TextEditingController _comentarioController = TextEditingController();

        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
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
                      'Comentarios (${comentarios.length})',
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
                  itemCount: comentarios.length,
                  itemBuilder: (context, index) {
                    final comentario = comentarios[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey[300],
                                radius: 16,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comentario.userUID ?? '',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(comentario.commentText ?? ''),
                                    Row(
                                      children: [
                                        Icon(Icons.favorite, size: 16, color: Colors.pink),
                                        SizedBox(width: 4),
                                        Text('${comentario.likesCount}'),
                                        SizedBox(width: 16),
                                        Icon(Icons.reply, size: 16, color: Colors.grey),
                                        SizedBox(width: 4),
                                        Text('${comentario.repliesCount}'),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.favorite_border, color: Colors.pink),
                                          onPressed: () async {
                                            final socialProvider = Provider.of<SocialProvider>(context, listen: false);
                                            final yaLikeado = await socialProvider.estaComentarioLikeado({
                                              'commentUID': comentario.commentUID,
                                              'userUID': miUsuarioId,
                                            });
                                            if (yaLikeado) {
                                              await socialProvider.quitarLikeComentario({
                                                'commentUID': comentario.commentUID,
                                                'userUID': miUsuarioId,
                                                'postUID': publicacion.postUID,
                                              });
                                            } else {
                                              await socialProvider.darLikeComentario({
                                                'commentUID': comentario.commentUID,
                                                'userUID': miUsuarioId,
                                                'postUID': publicacion.postUID,
                                              });
                                            }
                                            await socialProvider.cargarComentarios(publicacion.postUID);
                                          },
                                        ),
                                        Text('Me gusta'),
                                        SizedBox(width: 16),
                                        comentario.repliesCount > 0
                                            ? TextButton(
                                                onPressed: () async {
                                                  final socialProvider = Provider.of<SocialProvider>(context, listen: false);
                                                  await socialProvider.cargarReplies(comentario.commentUID);
                                                  final replies = Provider.of<SocialProvider>(context, listen: false).replies;
                                                  _mostrarRepliesModal(context, comentario.commentUID, publicacion.postUID);
                                                  await socialProvider.cargarComentarios(publicacion.postUID);
                                                },
                                                child: Text('Ver respuestas (${comentario.repliesCount})'),
                                              )
                                            : TextButton(
                                                onPressed: () async {
                                                  _mostrarReplies([], comentario.commentUID, publicacion.postUID);
                                                },
                                                child: Text('Responder'),
                                              ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Divider(),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
                child: TextField(
                  controller: _comentarioController,
                  decoration: InputDecoration(
                    hintText: 'Añadir un comentario...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.send, color: Colors.pink),
                      onPressed: () async {
                        await Provider.of<SocialProvider>(context, listen: false).crearComentario({
                          'postUID': publicacion.postUID,
                          'userUID': miUsuarioId,
                          'userName': nombreUsuario,
                          'avatarUrl': avatarUrl,
                          'commentText': _comentarioController.text,
                        });
                        _comentarioController.clear();
                        FocusScope.of(context).unfocus();
                        await Provider.of<SocialProvider>(context, listen: false).cargarComentarios(publicacion.postUID);
                        await Provider.of<SocialProvider>(context, listen: false).cargarPublicaciones();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

void _mostrarReplies(List<CommentRepliesModel> initialReplies, String commentUID, String postUID) {
  final viewModel = Provider.of<PerfilViewModel>(context, listen: false);
  String miUsuarioId = viewModel.userId;
  final TextEditingController _replyController = TextEditingController();

  // Lista local para manejar replies dentro del modal
  List<CommentRepliesModel> localReplies = List.from(initialReplies);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setStateModal) {
          return AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            curve: Curves.easeOut,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
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
                          'Respuestas (${localReplies.length})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: localReplies.length,
                      itemBuilder: (context, index) {
                        final reply = localReplies[index];
                        return ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(reply.userUID ?? ''),
                          subtitle: Text(reply.replyText ?? ''),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _replyController,
                            decoration: const InputDecoration(
                              hintText: 'Escribe una respuesta...',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.pink),
                          onPressed: () async {
                            if (_replyController.text.trim().isEmpty) return;

                            await Provider.of<SocialProvider>(context, listen: false)
                                .crearReply({
                              'commentUID': commentUID,
                              'userUID': miUsuarioId,
                              'replyText': _replyController.text.trim(),
                            });

                            _replyController.clear();

                            // Recargar replies desde el provider y actualizar la lista local
                            final nuevasReplies = await Provider.of<SocialProvider>(context, listen: false)
                                .cargarReplies(commentUID);

                            setStateModal(() {
                              localReplies = nuevasReplies;
                            });

                            // Recargar comentarios de la publicación (si quieres actualizar también)
                            await Provider.of<SocialProvider>(context, listen: false)
                                .cargarComentarios(postUID);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}


  void _mostrarRepliesModal(BuildContext context, String commentUID, String postUID) {
    Provider.of<SocialProvider>(context, listen: false).cargarReplies(commentUID).then((_) {
      final replies = Provider.of<SocialProvider>(context, listen: false).replies;
      _mostrarReplies(replies, commentUID, postUID);
    });
  }

  @override
  Widget build(BuildContext context) {
    final socialProvider = Provider.of<SocialProvider>(context);
    final publicaciones = socialProvider.publicaciones;
    final viewModel = Provider.of<PerfilViewModel>(context, listen: false);
      String miUsuarioId = viewModel.userId;
      String avatarUrl = viewModel.userImage;
    String token=getIt<AuthDataService>().getToken()!;


    return Scaffold(
      appBar: AppBar(
        title: Text('Feed Social', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.add_photo_alternate),
            onPressed: _mostrarOpcionesImagen,
          ),
        ],
      ),
      body: Column(
        children: [
          // Área de composición
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
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
                          fillColor: Theme.of(context).colorScheme.surface,
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
                                color: Theme.of(context).colorScheme.surface,
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
                      await socialProvider.cargarPublicaciones();
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.all(8.0),
                      itemCount: publicaciones.length,
                      itemBuilder: (context, index) {
                        return _buildPublicacionCard(
                          publicaciones[index],
                          LikesModel(
                            id: publicaciones[index].id,
                            postUID: publicaciones[index].postUID,
                            userUID: miUsuarioId,
                            date: publicaciones[index].createdAt,
                          ),
                        );
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

  Widget _buildPublicacionCard(SocialModel publicacion, LikesModel likes) {
    final fechaRelativa = timeago.format(publicacion.createdAt, locale: 'es');
    final String imageFileName = publicacion.imageURL;
    final String imageUrl = imageFileName;
    final viewModel = Provider.of<PerfilViewModel>(context, listen: false);
    String nombreUsuario = viewModel.userId;
      String miUsuarioId = viewModel.userId;
      String avatarUrl = viewModel.userImage;
    viewModel.getUserDataById(miUsuarioId).then((userData) {
      if (userData != null) {
        nombreUsuario = userData.userName;
        avatarUrl = userData.avatarUrl;
      }
    });

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(avatarUrl),
                  radius: 22,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombreUsuario,
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
            if (publicacion.description.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  publicacion.description,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            if (publicacion.imageURL != null && publicacion.imageURL.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: publicacion.description.isEmpty ? 12 : 0, bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildImageWidget(imageUrl),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 18,
                      color: Colors.pink,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${publicacion.likesCount}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
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
                        '${publicacion.commentsCount}',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () => _darLike(publicacion),
                  child: Row(
                    children: [
                      FutureBuilder<bool>(
                        future: Provider.of<SocialProvider>(context, listen: false)
                            .estaLikeado({'postUID': publicacion.postUID, 'userUID': miUsuarioId}),
                        builder: (context, snapshot) {
                          final likeado = snapshot.data ?? false;
                          return Icon(
                            likeado ? Icons.favorite : Icons.favorite_border,
                            color: likeado ? Colors.pink : Colors.grey.shade700,
                          );
                        },
                      ),
                      SizedBox(width: 4),
                      FutureBuilder<bool>(
                        future: Provider.of<SocialProvider>(context, listen: false)
                            .estaLikeado({'postUID': publicacion.postUID, 'userUID': miUsuarioId}),
                        builder: (context, snapshot) {
                          final likeado = snapshot.data ?? false;
                          return Text(
                            'Me gusta',
                            style: TextStyle(
                              color: likeado ? Colors.pink : Colors.grey.shade700,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
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

Widget _buildImageWidget(String imagePath) {
  if (imagePath.startsWith('http')) {
    return Image.network(
      headers: {'Authorization': 'Bearer ${getIt<AuthDataService>().getToken()}'},
      imagePath,
      height: 250,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 250,
          width: double.infinity,
          color: Theme.of(context).colorScheme.surface,
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
          color: Theme.of(context).colorScheme.surface,
          child: Center(
            child: Icon(Icons.broken_image, size: 40),
          ),
        );
      },
    );
  } else {
    final file = File(imagePath);
    if (!file.existsSync()) {
      // Si el archivo no existe, muestra un placeholder
      return Container(
        height: 250,
        width: double.infinity,
        color: Theme.of(context).colorScheme.surface,
        child: Center(
          child: Icon(Icons.broken_image, size: 40),
        ),
      );
    }
    return Image.file(
      file,
      height: 250,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 250,
          width: double.infinity,
          color: Theme.of(context).colorScheme.surface,
          child: Center(
            child: Icon(Icons.broken_image, size: 40),
          ),
        );
      },
    );
  }
}
}