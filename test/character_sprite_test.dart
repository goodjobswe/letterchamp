import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:letterchamp/widgets/character_sprite.dart';

void main() {
  testWidgets('the mascot blinks after a second and bobs every period', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CharacterSprite())),
    );

    String shownAsset() =>
        (tester.widget<Image>(find.byType(Image)).image as AssetImage)
            .assetName;
    // The app scaffolding has Transforms of its own; only the sprite's counts.
    final Finder spriteTransform =
        find
            .descendant(
              of: find.byType(CharacterSprite),
              matching: find.byType(Transform),
            )
            .first;
    double verticalOffset() =>
        tester.widget<Transform>(spriteTransform).transform.storage[13];

    expect(shownAsset(), CharacterSprite.eyesOpenAsset);
    expect(verticalOffset(), 0);

    // One bob period later the sprite sits one pixel higher.
    await tester.pump(CharacterSprite.bobPeriod);
    expect(verticalOffset(), lessThan(0));

    // The first blink starts one second in and lasts the blink duration.
    await tester.pump(
      CharacterSprite.firstBlinkDelay - CharacterSprite.bobPeriod,
    );
    expect(shownAsset(), CharacterSprite.eyesClosedAsset);
    await tester.pump(CharacterSprite.blinkDuration);
    expect(shownAsset(), CharacterSprite.eyesOpenAsset);

    // Another bob period brings the sprite back down.
    await tester.pump(CharacterSprite.bobPeriod);
    expect(verticalOffset(), 0);

    // Dispose the sprite so its timers do not outlive the test.
    await tester.pumpWidget(const SizedBox());
  });
}
