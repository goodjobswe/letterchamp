import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  testWidgets(
    'both app fonts load from bundled assets without network access',
    (tester) async {
      final previous = GoogleFonts.config.allowRuntimeFetching;
      GoogleFonts.config.allowRuntimeFetching = false;
      addTearDown(() => GoogleFonts.config.allowRuntimeFetching = previous);

      await tester.runAsync(() async {
        await GoogleFonts.pendingFonts([
          GoogleFonts.pressStart2p(),
          GoogleFonts.poppins(),
        ]);
      });
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Letter Champ', style: GoogleFonts.pressStart2p()),
                Text('Åäö', style: GoogleFonts.poppins()),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Letter Champ'), findsOneWidget);
      expect(find.text('Åäö'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
