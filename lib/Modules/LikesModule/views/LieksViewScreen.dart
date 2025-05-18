import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mascotas_citas/Modules/LikesModule/model/LikeModel.dart';
import 'package:mascotas_citas/Modules/LikesModule/state/LikeModuleState.dart';
import 'package:mascotas_citas/Modules/LikesModule/usecases/AcceptLikeUseCase.dart';
import 'package:mascotas_citas/Modules/LikesModule/usecases/RejectLikeUseCase.dart';
import 'package:mascotas_citas/Modules/LikesModule/usecases/RevealLikesUseCase.dart';
import 'package:mascotas_citas/dependencies/injector.dart';
import 'package:mascotas_citas/services/auth/AuthSesionDataService.dart';
import 'package:provider/provider.dart';

class LikesViewScreen extends StatefulWidget {
  const LikesViewScreen({super.key});

  @override
  State<LikesViewScreen> createState() => _LikesViewScreenState();
}

class _LikesViewScreenState extends State<LikesViewScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  int lastListLength = 0;

  void _addItem() {
    _listKey.currentState!.insertItem(0, duration: Duration(seconds: 1));
  }

  void _removeItem() {
    _listKey.currentState!.removeItem(0, (context, animation) {
      return Card();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: getIt<LikeModuleState>(),
      child: Consumer<LikeModuleState>(builder:
          (BuildContext context, LikeModuleState state, Widget? child) {
        if (state.lastListAction == "add") {
          if (lastListLength < state.likes.length) {
            lastListLength = state.likes.length;
            _addItem();
            state.lastListActionClear();
          }
        } else if (state.lastListAction == "remove") {
          if (_listKey.currentState != null && state.likes.isEmpty) {
            lastListLength = state.likes.length;
            _removeItem();
            state.lastListActionClear();
          }
        }

        return SizedBox.expand(
          child: Column(
            children: [
              Flexible(
                  fit: FlexFit.tight,
                  flex: 2,
                  child: Text("Se han interesado en ti")),
              Flexible(
                  fit: FlexFit.tight,
                  flex: 9,
                  child: LayoutBuilder(builder:
                      (BuildContext context, BoxConstraints constraints) {
                    return AnimatedList(
                        physics: NeverScrollableScrollPhysics(),
                        key: _listKey,
                        initialItemCount: state.likes.length,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index, animation) {
                          return LikeCard(constraints, state.likes[index]);
                        });
                  }))
            ],
          ),
        );
      }),
    );
  }

  Padding LikeCard(BoxConstraints constraints, LikeModel likeModel) {
    String? token = getIt<AuthDataService>().getToken();
    RejectLikeUseCase rejectLikeUseCase = getIt<RejectLikeUseCase>();
    AcceptLikeUseCase acceptLikeUseCase = getIt<AcceptLikeUseCase>();

    return Padding(
      padding: EdgeInsets.only(
          left: 10.0.w, right: 8.0.w, top: 8.0.h, bottom: 8.0.h),
      child: !likeModel.isRevealed
          ? unrevealedSide(constraints)
          : Container(
              height: constraints.maxHeight * 0.9,
              width: ScreenUtil.defaultSize.width,
              color: Colors.blue,
              child: Stack(
                fit: StackFit
                    .expand, // Hace que los widgets se expandan para llenar el espacio
                children: [
                  // Imagen de fondo
                  CachedNetworkImage(
                    imageUrl: likeModel.petPictureURL,
                    httpHeaders: {"Authorization": "Bearer $token"},
                    fit: BoxFit
                        .cover, // Asegura que la imagen cubra todo el contenedor
                    placeholder: (context, url) => SizedBox(
                        height: 100.h,
                        width: 100.w,
                        child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                  // Nombre en la esquina superior izquierda
                  Positioned(
                    top: 10.0, // Espacio desde la parte superior
                    left: 10.0, // Espacio desde la parte izquierda
                    child: Text(
                      likeModel.petName ?? "Sin nombre",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Botones sobre la imagen
                  Positioned(
                    bottom:
                        20.0, // Posición vertical de los botones (20 píxeles desde abajo)
                    left: 50.0, // Espacio desde la izquierda
                    right: 50.0, // Espacio desde la derecha
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            await acceptLikeUseCase.execute();
                          },
                          child: Text("Aceptar"),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            await rejectLikeUseCase.execute();
                          },
                          child: Text("Rechazar"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Container unrevealedSide(BoxConstraints constraints) {
    final revealLikeUseCase = getIt<RevealLikeUseCase>();

    return Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 216, 127, 127),
          borderRadius: BorderRadius.circular(10),
        ),
        height: constraints.maxHeight,
        width: ScreenUtil.defaultSize.width,
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Alguien interesado en ti",
              style: TextStyle(color: Colors.white, fontSize: 70.sp),
            ),
            SizedBox(height: 50.h),
            ElevatedButton(
                onPressed: () {
                  revealLikeUseCase.execute();
                },
                child: Text("Ver quien es"))
          ],
        )));
  }
}
