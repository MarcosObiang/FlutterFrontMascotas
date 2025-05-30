import 'package:mascotas_citas/Modules/ChatModule/state/ChatState.dart';
import 'package:mascotas_citas/Modules/LikesModule/model/LikeModel.dart';
import 'package:mascotas_citas/Modules/LikesModule/state/LikeModuleState.dart';
import 'package:mascotas_citas/interfaces/data_handler_interface.dart';
import 'package:mascotas_citas/interfaces/i_list_item_manager.dart';

class LikeDataHandlers
    implements
        DataProcessingStrategy<LikeModel, List<LikeModel>, LikeModuleState> {
  @override
  bool canProcess(dynamic data, LikeModuleState state) {
    if (data is! List<LikeModel>) {
      return false;
    }

    return true;
  }

  @override
  void process(List<LikeModel> data, LikeModuleState state) {
    state.likes= List.from(data);
    state.likes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    state.setLastListAction(action: LastListAction.add);
  }
}
