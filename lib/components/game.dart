import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_kenney_xml/flame_kenney_xml.dart';
import 'package:projects/components/background.dart';
import 'ground.dart';
import 'dart:math';
import 'brick.dart';
import 'player.dart';

class MyPhysicsGame extends Forge2DGame {
  MyPhysicsGame()
      : super(
          gravity: Vector2(0, 10),
          camera: CameraComponent.withFixedResolution(
            width: 800,
            height: 600,
          ),
        );

  late final XmlSpriteSheet aliens;
  late final XmlSpriteSheet elements;
  late final XmlSpriteSheet titles;

  @override
  Future<void> onLoad() async {
    final backgroundImage = await images.load('colored_grass.png');
    final spriteSheets = await Future.wait([
      XmlSpriteSheet.load(
        imagePath: 'spritesheet_aliens.png',
        xmlPath: 'spritesheet_aliens.xml',
      ),
      XmlSpriteSheet.load(
        imagePath: 'spritesheet_elements.png',
        xmlPath: 'spritesheet_elements.xml',
      ),
      XmlSpriteSheet.load(
        imagePath: 'spritesheet_tiles.png',
        xmlPath: 'spritesheet_tiles.xml',
      ),
    ]);

    aliens = spriteSheets[0];
    elements = spriteSheets[1];
    titles = spriteSheets[2];
    await world.add(
      Background(
        sprite: Sprite(backgroundImage),
      ),
    );
    await addGround();
    unawaited(addBricks());
    await addPlayer();
    return super.onLoad();
  }

  Future<void> addGround() {
    return world.addAll(
      [
        for (var x = camera.visibleWorldRect.left;
            x < camera.visibleWorldRect.right;
            x += groundSize)
          Ground(
            Vector2(x, (camera.visibleWorldRect.height - groundSize) / 2),
            titles.getSprite('grass.png'),
          ),
      ],
    );
  }

  final _random = Random();

  Future<void> addBricks() async {
    for (var i = 0; i < 5; i++) {
      final type = BrickType.randomType;
      final size = BrickSize.randomSize;

      await world.add(
        Brick(
          type: type,
          size: size,
          damage: BrickDamage.some,
          position: Vector2(
              camera.visibleWorldRect.right / 3 +
                  (_random.nextDouble() * 5 - 2.5),
              0),
          sprites: brickFileNames(type, size).map(
            (key, fileName) => MapEntry(
              key,
              elements.getSprite(fileName),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> addPlayer() async => world.add(
        Player(
          Vector2(camera.visibleWorldRect.left * 2 / 3, 0),
          aliens.getSprite(
            PlayerColor.randomColor.fileName,
          ),
        ),
      );

  @override
  void update(double dt) {
    super.update(dt);
    if (isMounted && world.children.whereType<Player>().isEmpty) {
      addPlayer();
    }
  }
}
