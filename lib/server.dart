library color_invasion.server;

import 'dart:io';
import 'dart:async';
import 'dart:json' as json;

import 'package:logging/logging.dart';

import 'shared.dart';

part 'src/server/player_info.dart';

// Tyrion: Where's the God of tits and wine?

class Server {
  List<Room> rooms = [];
  Map<WebSocketConnection, PlayerInfo> players = {};
  Logger logger = new Logger('color-invasion');

  Server() {
    // Create some default rooms...
    rooms.add(new Room()
      ..name = 'cc3'
      ..id = 1
      ..players = 2);

    hierarchicalLoggingEnabled = true;
    logger.level = Level.FINE;
    logger.onRecord.listen((LogRecord record) {
      print(record.message);
    });

    HttpServer.bind('0.0.0.0', 80).then((HttpServer server) {
      print('> Server is up.');

      server.listen((HttpRequest request) {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          WebSocketTransformer.upgrade(request).then(handleNewWebSocketConnection).catchError((e) => logger.severe('Error in upgrading WS connection: $e'));
        } else {
          handleHttpRequest(request);
        }
      }, onError: (e) => logger.severe('Error in HTTP server: $e'));
    }).catchError((e) => logger.severe('Error in binding HTTP server: $e'));
  }

  handleHttpRequest(HttpRequest request) {
    if (request.uri.path == '/') {
      serveFile(request, new File('web/index.html')).catchError(logger.severe);
    } else {
      serveFile(request, new File('web${request.uri.path}')).catchError(logger.severe);
    }
  }

  handleNewWebSocketConnection(WebSocket connection) {
    players[connection] = new PlayerInfo();

    connection.done.catchError((e) {
      logger.severe('Problem with WebSocket connection: $e');
      connection.close();
    }).whenComplete(() {
      players.remove(connection);
    });

    connection.listen((message) {
      var data = json.parse(message);

      if (data['action'] == 'findRooms') {
        var response = {};
        response['id'] = data['id'];
        response['data'] = findRooms();
        connection.add(json.stringify(response));
      }
    }, onDone: () {
      players.remove(connection);
    }, onError: (e) {
      print(e);
      connection.close();
    });
  }

  Future serveFile(HttpRequest request, File file) {
    return file.openRead().pipe(request.response);
  }

  /**
   * Finds all rooms.
   */
  List<Room> findRooms() => rooms; // lol...
}