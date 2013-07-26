part of color_invasion.client;

class Renderer {
  Game game;
  CanvasRenderingContext2D context;

  Renderer({this.game}) {
    // Set up the draw loop.
    window.animationFrame.then(draw);

    context = game.canvas.context2d;
  }

  num lastTime = 0;
  int ticks = 30;
  int fps = 0;

  void draw(num timestamp) {
    ticks++;

    if (ticks > 30) {
      var result = ((timestamp - lastTime) ~/ 30);
      if (result > 0) fps = 1000 ~/ result;

      ticks = 0;
      lastTime = timestamp;
    }

    context.clearRect(0, 0, game.canvas.width, game.canvas.height);

    drawGrid();
    drawEntities();

    context.font = '18px Arial';
    context.fillText('FPS: $fps', 16, 18 + 16);

    window.animationFrame.then(draw);
  }

  void drawEntities() {
    game.entities.forEach((Entity entity) {
      context.fillStyle = '#e90';
      context.fillRect(entity.position.x * game.blockSize, entity.position.y * game.blockSize, game.blockSize, game.blockSize);
    });
  }

  void drawGrid() {
    context.strokeStyle = '#f9f9f9';

    for (var x = 0; x <= game.canvas.width; x += game.blockSize) {
      for (var y = 0; y <= game.canvas.height; y += game.blockSize) {
        context.strokeRect(x, y, game.blockSize, game.blockSize);
      }
    }
  }
}