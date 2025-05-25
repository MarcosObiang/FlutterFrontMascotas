import 'package:mascotas_citas/Modules/ChatModule/state/ChatState.dart';
import 'package:mascotas_citas/interfaces/data_handler_interface.dart';

abstract class IListItemManager<TItem> {
  /// Lista de ítems que esta clase gestiona.
  List<TItem> get items;

  void setLastListAction({required LastListAction action});
}
