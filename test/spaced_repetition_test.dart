import 'package:flutter_test/flutter_test.dart';
import 'package:my_mezmure_dawit/data/models/memorization_progress.dart';

void main() {
  group('Spaced Repetition Algorithm Tests', () {
    test('Initial progress starts with level 0 and is not mastered', () {
      final progress = MemorizationProgress(
        verseId: 1001,
        psalmNumber: 1,
        verseNumber: 1,
        nextReviewDate: DateTime.now(),
      );

      expect(progress.repetitionLevel, 0);
      expect(progress.isMastered, isFalse);
    });

    test('Rating "easy" advances through the standard intervals (1d -> 3d -> 7d -> 14d -> 30d)', () {
      var progress = MemorizationProgress(
        verseId: 1001,
        psalmNumber: 1,
        verseNumber: 1,
        nextReviewDate: DateTime.now(),
      );

      // Attempt 1: Easy -> Level 1, interval 1 day
      progress = progress.applyReview('easy');
      expect(progress.repetitionLevel, 1);
      expect(progress.intervalDays, 1);
      expect(progress.isMastered, isFalse); // Not permanently memorized after 1 attempt!

      // Attempt 2: Easy -> Level 2, interval 3 days
      progress = progress.applyReview('easy');
      expect(progress.repetitionLevel, 2);
      expect(progress.intervalDays, 3);
      expect(progress.isMastered, isFalse);

      // Attempt 3: Easy -> Level 3, interval 7 days
      progress = progress.applyReview('easy');
      expect(progress.repetitionLevel, 3);
      expect(progress.intervalDays, 7);
      expect(progress.isMastered, isFalse);

      // Attempt 4: Easy -> Level 4, interval 14 days
      progress = progress.applyReview('easy');
      expect(progress.repetitionLevel, 4);
      expect(progress.intervalDays, 14);
      expect(progress.isMastered, isTrue); // Reached mastery threshold (Level 4)

      // Attempt 5: Easy -> Level 5, interval 30 days
      progress = progress.applyReview('easy');
      expect(progress.repetitionLevel, 5);
      expect(progress.intervalDays, 30);
      expect(progress.isMastered, isTrue);
    });

    test('Rating "forgot" resets interval to 1 day and level to 1', () {
      var progress = MemorizationProgress(
        verseId: 1001,
        psalmNumber: 1,
        verseNumber: 1,
        repetitionLevel: 3,
        intervalDays: 7,
        nextReviewDate: DateTime.now(),
      );

      progress = progress.applyReview('forgot');
      expect(progress.repetitionLevel, 1);
      expect(progress.intervalDays, 1);
      expect(progress.lastRating, 'forgot');
      expect(progress.isMastered, isFalse);
    });

    test('Rating "difficult" keeps review interval short (2 days)', () {
      var progress = MemorizationProgress(
        verseId: 1001,
        psalmNumber: 1,
        verseNumber: 1,
        repetitionLevel: 2,
        intervalDays: 3,
        nextReviewDate: DateTime.now(),
      );

      progress = progress.applyReview('difficult');
      expect(progress.intervalDays, 2);
      expect(progress.lastRating, 'difficult');
    });
  });
}
