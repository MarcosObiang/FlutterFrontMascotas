
// Posiblemente en: lib/common/domain/strategies/data_strategies.dart
// Asegúrate de importar IListItemManager si está en un archivo separado
import 'package:mascotas_citas/interfaces/i_list_item_manager.dart';




/// Enum que representa los posibles estados de una operación o del módulo.
enum Status { loading, initial, error, success }

/// Enum que representa la última acción realizada sobre la lista de chats.
enum LastListAction { add, remove, update, none }

/// Estrategia genérica para procesar datos y añadirlos/actualizarlos en un estado.
///
/// [TItem]       El tipo de ítem en la lista del estado (ej: LikeModel, ChatModel).
/// [TInputData]  El tipo de dato de entrada que esta estrategia espera (ej: WebSocketDataContainer<TItem>, List<TItem>).
/// [TState]      El tipo del estado que gestiona la lista. Debe implementar [IListItemManager<TItem>].
///               Se asume que TState también es un ChangeNotifier o tiene un mecanismo similar
///               para que `requestNotification()` funcione.
abstract class DataProcessingStrategy<TItem, TInputData, TState extends IListItemManager<TItem>> {
  /// Verifica si esta estrategia puede procesar los [data] dados para el [state] actual.
  ///
  /// El [state] se proporciona por si la decisión depende de alguna condición del estado.
  bool canProcess(TInputData data, TState state);

  /// Procesa los [data] y actualiza la lista `items` en el [state].
  ///
  /// Las implementaciones son responsables de modificar `state.items` y luego
  /// llamar a `state.requestNotification()` para reflejar los cambios.
  void process(TInputData data, TState state);
}

/// Estrategia genérica para eliminar datos de un estado.
///
/// [TItem]       El tipo de ítem en la lista del estado.
/// [TIdentifier] El tipo de identificador usado para la eliminación (ej: el propio TItem, un String para un ID).
/// [TState]      El tipo del estado que gestiona la lista. Debe implementar [IListItemManager<TItem>].
///               Se asume que TState también es un ChangeNotifier o tiene un mecanismo similar
///               para que `requestNotification()` funcione.
abstract class DataRemovalStrategy<TItem, TIdentifier, TState extends IListItemManager<TItem>> {
  /// Verifica si esta estrategia puede manejar la eliminación usando el [identifier]
  /// para el [state] actual.
  ///
  /// El [state] se proporciona por si la decisión depende de alguna condición del estado.
  bool canHandle(TIdentifier identifier, TState state);

  /// Elimina datos basándose en el [identifier] de la lista `items` en el [state].
  ///
  /// Las implementaciones son responsables de modificar `state.items` y luego
  /// llamar a `state.requestNotification()` para reflejar los cambios.
  void remove(TIdentifier identifier, TState state);
}
