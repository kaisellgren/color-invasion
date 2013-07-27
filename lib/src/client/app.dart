part of color_invasion.client;

class App {
  WebSocket connection = new WebSocket('ws://${window.location.host}/');
  List<Room> rooms = toObservable([]);

  String view = 'rooms'; // TODO: Maybe enums.

  int lastRequestId = 0;
  Map<int, Completer> requestCompleters = {};

  App() {
    query('#app').model = this;

    connection.onOpen.listen((_) => findRooms());

    connection.onClose.listen((_) {print('connection raped');});

    connection.onMessage.listen((e) {
      var data = json.parse(e.data);
      requestCompleters[data['id']].complete(data['data']);
    });
  }

  bool get isRoomsView => view == 'rooms';
  bool get isGameView => view == 'game';

  findRooms() {
    sendRequest({'action': 'findRooms'}).then((response) {
      response.forEach((r) {
        rooms.add(new Room.fromMap(r));
      });

      print(rooms);
    });
  }

  /**
   * Sends a request to the server, returns a future that completes with the response.
   */
  Future sendRequest(Map data) {
    var completer = new Completer();

    data['id'] = ++lastRequestId;
    requestCompleters[lastRequestId] = completer;

    connection.send(json.stringify(data));

    return completer.future;
  }
}