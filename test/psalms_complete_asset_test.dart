import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_mezmure_dawit/data/models/psalm.dart';
import 'package:my_mezmure_dawit/data/models/verse.dart';

void main() {
  group('Complete Canonical EOTC Psalter Dataset Tests', () {
    late List<Psalm> psalms;

    setUpAll(() {
      final file = File('assets/data/psalms_complete.json');
      expect(file.existsSync(), isTrue, reason: 'assets/data/psalms_complete.json must exist');
      final jsonString = file.readAsStringSync();
      final Map<String, dynamic> data = json.decode(jsonString) as Map<String, dynamic>;
      final List<dynamic> list = data['psalms'] as List<dynamic>;

      psalms = list.map((item) {
        final map = item as Map<String, dynamic>;
        final versesRaw = map['verses'] as List<dynamic>? ?? [];
        final verses = versesRaw.map((v) => Verse.fromMap(v as Map<String, dynamic>)).toList();
        return Psalm.fromMap(map, verses: verses);
      }).toList();
    });

    test('Contains exactly 151 canonical Psalms (1-150 + Psalm 151)', () {
      expect(psalms.length, 151);

      final numbers = psalms.map((p) => p.number).toList();
      for (int i = 1; i <= 151; i++) {
        expect(numbers.contains(i), isTrue, reason: 'Psalm $i is missing');
      }
    });

    test('Every Psalm has versesCount > 0 and matching verses list', () {
      int totalVerses = 0;
      for (final p in psalms) {
        expect(p.versesCount, greaterThan(0), reason: 'Psalm ${p.number} has 0 verses');
        expect(p.verses.length, equals(p.versesCount),
            reason: 'Psalm ${p.number} versesCount mismatch');
        totalVerses += p.versesCount;

        // Verify each verse has complete Ge'ez, Amharic, and English text
        for (final v in p.verses) {
          expect(v.textGeez.trim().isNotEmpty, isTrue,
              reason: 'Psalm ${p.number} v${v.verseNumber} missing Ge\'ez');
          expect(v.textAmharic.trim().isNotEmpty, isTrue,
              reason: 'Psalm ${p.number} v${v.verseNumber} missing Amharic');
          expect(v.textEnglish.trim().isNotEmpty, isTrue,
              reason: 'Psalm ${p.number} v${v.verseNumber} missing English');
        }
      }
      expect(totalVerses, 2593, reason: 'Expected exactly 2593 canonical verses');
    });

    test('Psalm 151 (ተወሳኪ መዝሙር ዘዳዊት) has authentic EOTC text', () {
      final p151 = psalms.firstWhere((p) => p.number == 151);
      expect(p151.versesCount, 8);
      expect(p151.verses.first.textGeez, contains('ንኡስ አነ'));
      expect(p151.verses.first.textAmharic, contains('ታናሽ ነበርሁ'));
      expect(p151.verses.last.textGeez, contains('ወተፈሥሑ ኵሎሙ ሕዝብ'));
    });

    test('Psalm 23 (እግዚአብሔር እረኛዬ ነው / ይሬዕየኒ) has 6 verses', () {
      final p23 = psalms.firstWhere((p) => p.number == 23);
      expect(p23.versesCount, 6);
      expect(p23.verses.first.textGeez, contains('እግዚአብሔር ፡ ይሬዕየኒ'));
      expect(p23.verses.first.textAmharic, contains('እግዚአብሔር፡እረኛዬ፡ነው'));
    });
  });
}
