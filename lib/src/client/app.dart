part of color_invasion.client;

class App {
  WebSocket connection = new WebSocket('ws://${window.location.host}/');
  List<Room> rooms = toObservable([]);
  Room room;
  List<Player> players = toObservable([]);

  @observable String view = 'rooms'; // TODO: Maybe enums.

  int lastRequestId = 0;
  Map<int, Completer> requestCompleters = {};

  App() {
    query('#app').model = this;

    connection.onOpen.listen((_) {
      joinRoom(id: 1);
      //findRooms();
    });

    connection.onClose.listen((_) {print('connection raped');});

    connection.onMessage.listen((e) {
      var data = json.parse(e.data);
      requestCompleters[data['id']].complete(data['data']);
    });
  }

  bool get isRoomsView => view == 'rooms';
  bool get isGameView => view == 'game';
  bool get isLobbyView => view == 'lobby';

  start() {
    print('y');
  }

  findRooms() {
    sendRequest({'action': 'findRooms'}).then((response) {
      response.forEach((r) {
        rooms.add(new Room.fromMap(r));
      });
    });
  }

  findPlayers() {
    sendRequest({'action': 'findPlayers'}).then((response) {
      print(response);
      players.clear();
      response.forEach((r) {
        players.add(new Player.fromMap(r));
      });
    });
  }

  joinRoom({int id}) {
    sendRequest({'action': 'joinRoom', 'id': id}).then((response) {
      view = 'lobby';

      findPlayers();
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