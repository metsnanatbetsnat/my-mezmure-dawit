/// Spaced Repetition progress state for an individual verse.
class MemorizationProgress {
  final int verseId;
  final int psalmNumber;
  final int verseNumber;
  final int repetitionLevel; // 0 = Unstudied, 1 = 1d, 2 = 3d, 3 = 7d, 4 = 14d, 5 = 30d (Mastered)
  final int intervalDays;
  final double easeFactor; // default 2.5
  final DateTime? lastReviewedAt;
  final DateTime nextReviewDate;
  final int successfulRecalls;
  final int failedRecalls;
  final String lastRating; // 'easy', 'difficult', 'forgot', or ''

  static const List<int> standardIntervals = [1, 3, 7, 14, 30];

  const MemorizationProgress({
    required this.verseId,
    required this.psalmNumber,
    required this.verseNumber,
    this.repetitionLevel = 0,
    this.intervalDays = 1,
    this.easeFactor = 2.5,
    this.lastReviewedAt,
    required this.nextReviewDate,
    this.successfulRecalls = 0,
    this.failedRecalls = 0,
    this.lastRating = '',
  });

  bool get isMastered => repetitionLevel >= 4;

  bool get isDueForReview {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return nextReviewDate.isBefore(todayMidnight);
  }

  bool get isDifficult => lastRating == 'difficult';
  bool get isForgotten => lastRating == 'forgot';

  /// Calculate the next spaced repetition state based on the user's self-evaluation rating.
  /// [rating]: 'easy' (I remembered it), 'difficult' (needed help), 'forgot' (could not remember)
  MemorizationProgress applyReview(String rating) {
    final now = DateTime.now();
    int newLevel = repetitionLevel;
    int newInterval = intervalDays;
    double newEase = easeFactor;
    int success = successfulRecalls;
    int fail = failedRecalls;

    if (rating == 'easy') {
      success += 1;
      newLevel = (repetitionLevel + 1).clamp(1, 5);
      // Interval progression: 1d -> 3d -> 7d -> 14d -> 30d
      final idx = (newLevel - 1).clamp(0, standardIntervals.length - 1);
      newInterval = standardIntervals[idx];
      newEase = (easeFactor + 0.1).clamp(1.3, 3.0);
    } else if (rating == 'difficult') {
      // Retain or slight advance, keep interval short (1 to 2 days)
      newInterval = 2;
      newLevel = repetitionLevel.clamp(1, 3);
      newEase = (easeFactor - 0.15).clamp(1.3, 3.0);
    } else {
      // Forgot: reset to beginning
      fail += 1;
      newLevel = 1;
      newInterval = 1;
      newEase = (easeFactor - 0.25).clamp(1.3, 3.0);
    }

    final nextReview = DateTime(now.year, now.month, now.day).add(Duration(days: newInterval));

    return MemorizationProgress(
      verseId: verseId,
      psalmNumber: psalmNumber,
      verseNumber: verseNumber,
      repetitionLevel: newLevel,
      intervalDays: newInterval,
      easeFactor: newEase,
      lastReviewedAt: now,
      nextReviewDate: nextReview,
      successfulRecalls: success,
      failedRecalls: fail,
      lastRating: rating,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'verseId': verseId,
      'psalmNumber': psalmNumber,
      'verseNumber': verseNumber,
      'repetitionLevel': repetitionLevel,
      'intervalDays': intervalDays,
      'easeFactor': easeFactor,
      'lastReviewedAt': lastReviewedAt?.toIso8601String(),
      'nextReviewDate': nextReviewDate.toIso8601String(),
      'successfulRecalls': successfulRecalls,
      'failedRecalls': failedRecalls,
      'lastRating': lastRating,
    };
  }

  factory MemorizationProgress.fromMap(Map<String, dynamic> map) {
    return MemorizationProgress(
      verseId: map['verseId'] as int,
      psalmNumber: map['psalmNumber'] as int,
      verseNumber: map['verseNumber'] as int,
      repetitionLevel: map['repetitionLevel'] as int? ?? 0,
      intervalDays: map['intervalDays'] as int? ?? 1,
      easeFactor: (map['easeFactor'] as num?)?.toDouble() ?? 2.5,
      lastReviewedAt: map['lastReviewedAt'] != null
          ? DateTime.tryParse(map['lastReviewedAt'] as String)
          : null,
      nextReviewDate: map['nextReviewDate'] != null
          ? DateTime.parse(map['nextReviewDate'] as String)
          : DateTime.now(),
      successfulRecalls: map['successfulRecalls'] as int? ?? 0,
      failedRecalls: map['failedRecalls'] as int? ?? 0,
      lastRating: map['lastRating'] as String? ?? '',
    );
  }
}
