import 'package:flutter_test/flutter_test.dart';
import 'package:my_mezmure_dawit/data/datasources/psalm_sample_data.dart';

void main() {
  group('Psalm Data Structure Tests', () {
    test('Loads complete canonical Ethiopian Orthodox Psalms (150 + Psalm 151)', () {
      final psalms = PsalmSampleData.getInitialPsalms();
      expect(psalms.length, 151);

      // Verify numbers 1 to 151 exist
      final numbers = psalms.map((p) => p.number).toSet();
      for (int i = 1; i <= 151; i++) {
        expect(numbers.contains(i), isTrue, reason: 'Psalm $i is missing');
      }
    });

    test('Core Psalms have authentic Amharic, Ge\'ez, and English text', () {
      final psalms = PsalmSampleData.getInitialPsalms();

      // Psalm 1
      final psalm1 = psalms.firstWhere((p) => p.number == 1);
      expect(psalm1.verses.length, 6);
      expect(psalm1.verses.first.textAmharic, contains('ምስጉን ነው'));
      expect(psalm1.verses.first.textGeez, contains('ብፁዕ ብእሲ'));
      expect(psalm1.verses.first.textEnglish, contains('Blessed is the man'));

      // Psalm 23
      final psalm23 = psalms.firstWhere((p) => p.number == 23);
      expect(psalm23.verses.length, 6);
      expect(psalm23.verses.first.textAmharic, contains('እግዚአብሔር እረኛዬ ነው'));
      expect(psalm23.verses.first.textGeez, contains('እግዚአብሔር ይርዕየኒ'));

      // Psalm 50
      final psalm50 = psalms.firstWhere((p) => p.number == 50);
      expect(psalm50.verses.first.textAmharic, contains('አቤቱ፥ እንደ ቸርነትህ መጠን ማረኝ'));

      // Psalm 150
      final psalm150 = psalms.firstWhere((p) => p.number == 150);
      expect(psalm150.verses.first.textAmharic, contains('እግዚአብሔርን በመቅደሱ አመስግኑት'));
    });
  });
}
