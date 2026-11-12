class ReviewRecord {
  final int? id;
  final int verseId;
  final int psalmNumber;
  final int verseNumber;
  final String modeUsed; // 'read', 'hidden_words', 'recall', 'recitation'
  final String rating; // 'easy', 'difficult', 'forgot'
  final DateTime reviewedAt;
  final int intervalDays;

  const ReviewRecord({
    this.id,
    required this.verseId,
    required this.psalmNumber,
    required this.verseNumber,
    required this.modeUsed,
    required this.rating,
    required this.reviewedAt,
    required this.intervalDays,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'verseId': verseId,
      'psalmNumber': psalmNumber,
      'verseNumber': verseNumber,
      'modeUsed': modeUsed,
      'rating': rating,
      'reviewedAt': reviewedAt.toIso8601String(),
      'intervalDays': intervalDays,
    };
  }

  factory ReviewRecord.fromMap(Map<String, dynamic> map) {
    return ReviewRecord(
      id: map['id'] as int?,
      verseId: map['verseId'] as int,
      psalmNumber: map['psalmNumber'] as int,
      verseNumber: map['verseNumber'] as int,
      modeUsed: map['modeUsed'] as String,
      rating: map['rating'] as String,
      reviewedAt: DateTime.parse(map['reviewedAt'] as String),
      intervalDays: map['intervalDays'] as int? ?? 1,
    );
  }
}
