import 'package:mascotas_citas/Modules/ChatModule/state/ChatState.dart';
import 'package:mascotas_citas/Modules/LikesModule/model/LikeModel.dart';
import 'package:mascotas_citas/Modules/LikesModule/state/LikeModuleState.dart';
import 'package:mascotas_citas/Modules/WebSocketModule/WebSocketDataContainer.dart';
import 'package:mascotas_citas/interfaces/data_handler_interface.dart';

class RealTimeAddLikeHandler
    implements
        DataProcessingStrategy<LikeModel, WebSocketDataContainer<LikeModel>,
            LikeModuleState> {
  @override
  bool canProcess(dynamic data, LikeModuleState state) {
    if (data == null) {
      return false;
    }

    if (data is! WebSocketDataContainer<LikeModel>) {
      return false;
    }

    return data.eventType == ReealtimeEventType.CREATE;
  }

  @override
  void process(WebSocketDataContainer<LikeModel> data, LikeModuleState state) {
    if (data.body == null) {
      return;
    }

    // Verifica si el like ya existe en la lista
    if (state.likes.any((like) => like.likeUID == data.body!.likeUID)) {
      // Si ya existe, no lo añade
      return;
    }

    state.likes=List.from(state.likes)..add(data.body!);
    // Ordena la lista de likes por fecha de creación
    state.likes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    // Actualiza el estado de la lista
    if (state.likes.isEmpty) {
      state.likes = List.empty(growable: true);
    }
    state.setLastListAction(action: LastListAction.add);
  }
}













class RealTimeUpdateLikeHandler
    implements
        DataProcessingStrategy<LikeModel, WebSocketDataContainer<LikeModel>,
            LikeModuleState> {
  @override
  bool canProcess(dynamic data, LikeModuleState state) {
    if (data == null) {
      return false;
    }

    if (data is! WebSocketDataContainer<LikeModel>) {
      return false;
    }
    return data.eventType == ReealtimeEventType.UPDATE;
  }

  @override
  void process(WebSocketDataContainer<LikeModel> data, LikeModuleState state) {
    // Busca el índice del like a actualizar
    int index =
        state.likes.indexWhere((like) => like == data.body);

    // Si el like no existe, no se hace nada
    if (index == -1) {
      return;
    }

    // Actualiza el like en la lista
    state.likes[index] = data.body!;
    state.setLastListAction(action: LastListAction.update);
  }
}

class RealTimeDeleteLikeHandler
    implements
        DataProcessingStrategy<LikeModel, WebSocketDataContainer<LikeModel>,
            LikeModuleState> {
  @override
  bool canProcess(dynamic data, LikeModuleState state) {
    if (data == null) {
      return false;
    }

    if (data is! WebSocketDataContainer<LikeModel>) {
      return false;
    }
    return data.eventType == ReealtimeEventType.DELETED;
  }

  @override
  void process(WebSocketDataContainer<LikeModel> data, LikeModuleState state) {
    // Busca el índice del like a eliminar
    int index = state.likes.indexWhere((like) => like.likeUID == data.resourceUID);

    // Si el like no existe, no se hace nada
    if (index == -1) {
      return;
    }

    // Elimina el like de la lista
    state.likes.removeAt(index);
    state.setLastListAction(action: LastListAction.remove);
  }
}
