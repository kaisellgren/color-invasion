part of color_invasion.shared;

class Room {
  int id;
  String name;
  int players;

  Room();

  factory Room.fromMap(Map data) {
    return new Room()
      ..id = data['id']
      ..name = data['name']
      ..players = data['players'];
  }

  Map toJson() {
    return {
      'id': id,
      'name': name,
      'players': players
    };
  }
}