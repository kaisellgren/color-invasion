part of color_invasion.shared;

class Player {
  Room room;
  String name = 'test';

  Player();

  factory Player.fromMap(Map data) {
    return new Player()
      ..name = data['name'];
  }

  Map toJson() {
    return {
      'name': name,
    };
  }
}