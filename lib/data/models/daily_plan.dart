class DailyPlan {
  final String dateKey; // 'yyyy-MM-dd'
  final int psalmNumber;
  final int startVerse;
  final int endVerse;
  final bool isReviewDay;
  final bool isCompleted;
  final String title;

  const DailyPlan({
    required this.dateKey,
    required this.psalmNumber,
    required this.startVerse,
    required this.endVerse,
    this.isReviewDay = false,
    this.isCompleted = false,
    this.title = '',
  });

  DailyPlan copyWith({
    String? dateKey,
    int? psalmNumber,
    int? startVerse,
    int? endVerse,
    bool? isReviewDay,
    bool? isCompleted,
    String? title,
  }) {
    return DailyPlan(
      dateKey: dateKey ?? this.dateKey,
      psalmNumber: psalmNumber ?? this.psalmNumber,
      startVerse: startVerse ?? this.startVerse,
      endVerse: endVerse ?? this.endVerse,
      isReviewDay: isReviewDay ?? this.isReviewDay,
      isCompleted: isCompleted ?? this.isCompleted,
      title: title ?? this.title,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateKey': dateKey,
      'psalmNumber': psalmNumber,
      'startVerse': startVerse,
      'endVerse': endVerse,
      'isReviewDay': isReviewDay ? 1 : 0,
      'isCompleted': isCompleted ? 1 : 0,
      'title': title,
    };
  }

  factory DailyPlan.fromMap(Map<String, dynamic> map) {
    return DailyPlan(
      dateKey: map['dateKey'] as String,
      psalmNumber: map['psalmNumber'] as int,
      startVerse: map['startVerse'] as int,
      endVerse: map['endVerse'] as int,
      isReviewDay: (map['isReviewDay'] as int? ?? 0) == 1,
      isCompleted: (map['isCompleted'] as int? ?? 0) == 1,
      title: map['title'] as String? ?? '',
    );
  }
}
