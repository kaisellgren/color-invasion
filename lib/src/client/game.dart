part of color_invasion.client;

class Game {
  CanvasElement canvas;
  Renderer renderer;

  List<Entity> entities = [];

  // Settings.
  int blockSize = 48; // Excluding borders.

  Game({this.canvas}) {
    resizeCanvas();

    renderer = new Renderer(game: this);

    // Make sure our canvas is always taking all space.
    window.onResize.listen((_) => resizeCanvas());

    // Listen to clicks.
    canvas.onMouseUp.listen((e) {
      var position = getPositionFromCoordinates(x: e.clientX, y: e.clientY - 48); // 48 is the toolbar height.

      // Add a piece to the position.
      var piece = new Piece();
      piece.position = position;

      entities.add(piece);
    });
  }

  void resizeCanvas() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight - 48;
  }

  /**
   * Turns screen "X, Y" pixel position into actual Vector2 position where e.g. "1, 2" represents the second block from third row.
   */
  Position getPositionFromCoordinates({x, y}) => new Position((x / blockSize).floor(), (y / blockSize).floor());
}