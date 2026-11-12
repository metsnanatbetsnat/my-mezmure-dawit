import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_mezmure_dawit/main.dart';
import 'package:my_mezmure_dawit/core/database/database_helper.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await DatabaseHelper.instance.init();
  });

  testWidgets('Renders my Mezmure Dawit app with navigation tabs and psalm song memorization', (WidgetTester tester) async {
    await tester.pumpWidget(const MyMezmureDawitApp());
    await tester.pumpAndSettle();

    // Verify app title and Mezmure Dawit header
    expect(find.text('መዝሙረ ዳዊት'), findsOneWidget);
    expect(find.text('Mezmure Dawit'), findsOneWidget);

    // Verify 5 bottom navigation items exist with authentic Ethiopic labels
    expect(find.text('ዋና'), findsOneWidget);
    expect(find.text('መዝሙራት'), findsOneWidget);
    expect(find.text('ሸምድድ'), findsOneWidget);
    expect(find.text('ዕድገት'), findsOneWidget);
    expect(find.text('መገለጫ'), findsOneWidget);

    // Tap on Psalms tab (መዝሙራት)
    await tester.tap(find.text('መዝሙራት'));
    await tester.pumpAndSettle();
    expect(find.text('መጽሐፈ መዝሙር ዘዳዊት (፻፶፩)'), findsOneWidget);

    // Tap on Practice/Memorize tab (ሸምድድ)
    await tester.tap(find.text('ሸምድድ'));
    await tester.pumpAndSettle();
    expect(find.text('የግዕዝ መሸምደጃ ክፍል'), findsOneWidget);

    // Tap on Progress tab (ዕድገት)
    await tester.tap(find.text('ዕድገት'));
    await tester.pumpAndSettle();
    expect(find.text('አጠቃላይ የሽምደዳ ዕድገት'), findsOneWidget);

    // Tap on Profile tab (መገለጫ)
    await tester.tap(find.text('መገለጫ'));
    await tester.pumpAndSettle();
    expect(find.text('መገለጫ እና ማስተካከያ'), findsOneWidget);
  });
}
