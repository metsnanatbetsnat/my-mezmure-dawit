import 'verse.dart';
import '../../core/constants/ethiopic_numerals.dart';

class Psalm {
  final int number;
  final String titleAmharic;
  final String titleGeez;
  final String titleEnglish;
  final String? liturgicalNote;
  final int versesCount;
  final List<Verse> verses;
  final bool isBookmarked;
  final int memorizedVersesCount;
  final DateTime? lastReadDate;

  const Psalm({
    required this.number,
    required this.titleAmharic,
    this.titleGeez = '',
    this.titleEnglish = '',
    this.liturgicalNote,
    required this.versesCount,
    this.verses = const [],
    this.isBookmarked = false,
    this.memorizedVersesCount = 0,
    this.lastReadDate,
  });

  String get ethiopicNumber => EthiopicNumerals.toEthiopic(number);

  double get memorizationRatio =>
      versesCount > 0 ? (memorizedVersesCount / versesCount).clamp(0.0, 1.0) : 0.0;

  bool get isFullyMemorized => versesCount > 0 && memorizedVersesCount >= versesCount;

  Psalm copyWith({
    int? number,
    String? titleAmharic,
    String? titleGeez,
    String? titleEnglish,
    String? liturgicalNote,
    int? versesCount,
    List<Verse>? verses,
    bool? isBookmarked,
    int? memorizedVersesCount,
    DateTime? lastReadDate,
  }) {
    return Psalm(
      number: number ?? this.number,
      titleAmharic: titleAmharic ?? this.titleAmharic,
      titleGeez: titleGeez ?? this.titleGeez,
      titleEnglish: titleEnglish ?? this.titleEnglish,
      liturgicalNote: liturgicalNote ?? this.liturgicalNote,
      versesCount: versesCount ?? this.versesCount,
      verses: verses ?? this.verses,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      memorizedVersesCount: memorizedVersesCount ?? this.memorizedVersesCount,
      lastReadDate: lastReadDate ?? this.lastReadDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'titleAmharic': titleAmharic,
      'titleGeez': titleGeez,
      'titleEnglish': titleEnglish,
      'liturgicalNote': liturgicalNote,
      'versesCount': versesCount,
      'isBookmarked': isBookmarked ? 1 : 0,
      'memorizedVersesCount': memorizedVersesCount,
      'lastReadDate': lastReadDate?.toIso8601String(),
    };
  }

  factory Psalm.fromMap(Map<String, dynamic> map, {List<Verse> verses = const []}) {
    return Psalm(
      number: map['number'] as int,
      titleAmharic: map['titleAmharic'] as String? ?? 'መዝሙር ${map['number']}',
      titleGeez: map['titleGeez'] as String? ?? '',
      titleEnglish: map['titleEnglish'] as String? ?? 'Psalm ${map['number']}',
      liturgicalNote: map['liturgicalNote'] as String?,
      versesCount: map['versesCount'] as int? ?? verses.length,
      verses: verses,
      isBookmarked: map['isBookmarked'] is bool
          ? map['isBookmarked'] as bool
          : (map['isBookmarked'] as int? ?? 0) == 1,
      memorizedVersesCount: map['memorizedVersesCount'] as int? ?? 0,
      lastReadDate: map['lastReadDate'] != null
          ? DateTime.tryParse(map['lastReadDate'] as String)
          : null,
    );
  }
}
