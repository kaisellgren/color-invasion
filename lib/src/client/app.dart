part of color_invasion.client;

class App extends ObservableBase {
  WebSocket connection = new WebSocket('ws://${window.location.host}/');
  List<Room> rooms = toObservable([]);
  Room room;
  List<Player> players = toObservable([]);

  var _displayRoomsView = 'block';
  String get displayRoomsView => _displayRoomsView;
  set displayRoomsView(String value) {
    _displayRoomsView = notifyPropertyChange(const Symbol('displayRoomsView'), _displayRoomsView, value);
  }

  var _displayLobbyView = 'none';
  String get displayLobbyView => _displayLobbyView;
  set displayLobbyView(String value) {
    _displayLobbyView = notifyPropertyChange(const Symbol('displayLobbyView'), _displayLobbyView, value);
  }

  var _displayGameView = 'none';
  String get displayGameView => _displayGameView;
  set displayGameView(String value) {
    v = notifyPropertyChange(const Symbol('displayGameView'), _displayGameView, value);
  }

  int lastRequestId = 0;
  Map<int, Completer> requestCompleters = {};

  App() {
    mdv.initialize();

    query('#app').model = this;

    connection.onOpen.listen((_) {
      joinRoom(id: 1); // For fast dev, let's join a room immediately (server created it already).
      //findRooms();
    });

    connection.onClose.listen((_) {print('connection raped');});

    connection.onMessage.listen((e) {
      var data = json.parse(e.data);
      requestCompleters[data['id']].complete(data['data']);
    });
  }

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
      players.clear();
      response.forEach((r) {
        players.add(new Player.fromMap(r));
      });
    });
  }

  joinRoom({int id}) {
    sendRequest({'action': 'joinRoom', 'id': id}).then((response) {
      print('Joined room #$id!');

      displayRoomsView = 'none';
      displayLobbyView = 'block';

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