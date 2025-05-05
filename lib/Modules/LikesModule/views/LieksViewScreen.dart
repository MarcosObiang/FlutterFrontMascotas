import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mascotas_citas/Modules/LikesModule/state/LikeModuleState.dart';
import 'package:mascotas_citas/dependencies/injector.dart';
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
        state.listUpdateInfo!.stream.listen((event) {
          if (event == "add") {
            if (lastListLength < state.likes.length) {
              lastListLength = state.likes.length;
              _addItem();
            }
          } else {
            _removeItem();
          }
        });
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
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index, animation) {
                          return Padding(
                            padding: EdgeInsets.only(
                                left: 10.0.w,
                                right: 8.0.w,
                                top: 8.0.h,
                                bottom: 8.0.h),
                            child: Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 216, 127, 127),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                height: constraints.maxHeight,
                                width: ScreenUtil.defaultSize.width,
                                child: Center(child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("Alguien interesado en ti",style: TextStyle(color: Colors.white,fontSize: 70.sp),),
                                    ElevatedButton(onPressed: (){

                                    }, child: Text("Ver quien es"))
                                  ],
                                ))),
                          );
                        });
                  }))
            ],
          ),
        );
      }),
    );
  }
}
