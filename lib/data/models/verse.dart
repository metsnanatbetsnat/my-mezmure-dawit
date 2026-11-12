class Verse {
  final int id;
  final int psalmNumber;
  final int verseNumber;
  final String textAmharic;
  final String textGeez;
  final String textEnglish;
  final bool isBookmarked;
  final String? audioPath;

  const Verse({
    required this.id,
    required this.psalmNumber,
    required this.verseNumber,
    required this.textAmharic,
    this.textGeez = '',
    this.textEnglish = '',
    this.isBookmarked = false,
    this.audioPath,
  });

  Verse copyWith({
    int? id,
    int? psalmNumber,
    int? verseNumber,
    String? textAmharic,
    String? textGeez,
    String? textEnglish,
    bool? isBookmarked,
    String? audioPath,
  }) {
    return Verse(
      id: id ?? this.id,
      psalmNumber: psalmNumber ?? this.psalmNumber,
      verseNumber: verseNumber ?? this.verseNumber,
      textAmharic: textAmharic ?? this.textAmharic,
      textGeez: textGeez ?? this.textGeez,
      textEnglish: textEnglish ?? this.textEnglish,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      audioPath: audioPath ?? this.audioPath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'psalmNumber': psalmNumber,
      'verseNumber': verseNumber,
      'textAmharic': textAmharic,
      'textGeez': textGeez,
      'textEnglish': textEnglish,
      'isBookmarked': isBookmarked ? 1 : 0,
      'audioPath': audioPath,
    };
  }

  factory Verse.fromMap(Map<String, dynamic> map) {
    return Verse(
      id: map['id'] as int,
      psalmNumber: map['psalmNumber'] as int,
      verseNumber: map['verseNumber'] as int,
      textAmharic: map['textAmharic'] as String? ?? '',
      textGeez: map['textGeez'] as String? ?? '',
      textEnglish: map['textEnglish'] as String? ?? '',
      isBookmarked: map['isBookmarked'] is bool
          ? map['isBookmarked'] as bool
          : (map['isBookmarked'] as int? ?? 0) == 1,
      audioPath: map['audioPath'] as String?,
    );
  }
}
