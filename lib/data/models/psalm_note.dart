class PsalmNote {
  final int? id;
  final int psalmNumber;
  final int? verseNumber;
  final String content;
  final String? reflection;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PsalmNote({
    this.id,
    required this.psalmNumber,
    this.verseNumber,
    required this.content,
    this.reflection,
    required this.createdAt,
    required this.updatedAt,
  });

  PsalmNote copyWith({
    int? id,
    int? psalmNumber,
    int? verseNumber,
    String? content,
    String? reflection,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PsalmNote(
      id: id ?? this.id,
      psalmNumber: psalmNumber ?? this.psalmNumber,
      verseNumber: verseNumber ?? this.verseNumber,
      content: content ?? this.content,
      reflection: reflection ?? this.reflection,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'psalmNumber': psalmNumber,
      'verseNumber': verseNumber,
      'content': content,
      'reflection': reflection,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PsalmNote.fromMap(Map<String, dynamic> map) {
    return PsalmNote(
      id: map['id'] as int?,
      psalmNumber: map['psalmNumber'] as int,
      verseNumber: map['verseNumber'] as int?,
      content: map['content'] as String,
      reflection: map['reflection'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
