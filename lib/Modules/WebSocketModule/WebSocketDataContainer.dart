enum ReealtimeEventType {
  CREATE,
  DELETED,
  UPDATE,
}

/// A container for data received through a WebSocket connection.
///
/// This class encapsulates the type of event, the data itself, and metadata
/// such as the resource UID, receiver UID, and data type.
class WebSocketDataContainer<T> {
  /// The type of event that triggered the data transmission.
  ReealtimeEventType eventType;

  /// The actual data being transmitted. Can be null if the event doesn't carry data.
  T? body;

  /// The unique identifier of the resource related to the data.
  String resourceUID;

  /// The unique identifier of the intended recipient of the data.
  String receiverUID;

  /// The type of data being transmitted (e.g., "like", "message").
  String dataType;

  /// Constructs a [WebSocketDataContainer].
  WebSocketDataContainer(
      {required this.eventType,
      required this.body,
      required this.resourceUID,
      required this.receiverUID,
      required this.dataType});
  
  /// Creates a [WebSocketDataContainer] from a JSON map.
  ///
  /// The JSON map should contain the following keys:
  /// - "eventType": A string representing the event type (e.g., "CREATED", "DELETED", "UPDATED").
  /// - "body": The actual data being transmitted.
  /// - "resourceUID": The unique identifier of the resource.
  /// - "receiverUID": The unique identifier of the receiver.
  /// - "dataType": The type of data being transmitted.
  factory WebSocketDataContainer.fromJson(Map<String, dynamic> json) {
    return WebSocketDataContainer(
      eventType: ReealtimeEventType.values.byName(json["eventType"]),
      body: json["body"]??null,
      resourceUID: json["resourceUID"],
      receiverUID: json["receiverUID"],
      dataType: json["dataType"],
    );
  }
}
