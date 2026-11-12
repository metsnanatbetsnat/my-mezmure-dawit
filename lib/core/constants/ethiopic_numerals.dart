/// Utility to convert between Arabic numbers (1, 2, 3...) and
/// traditional Ethiopic Ge'ez numerals (፩, ፪, ፫, ፬, ፭, ፮, ፯, ፰, ፱, ፲...).
class EthiopicNumerals {
  static const List<String> _ones = [
    '', '፩', '፪', '፫', '፬', '፭', '፮', '፯', '፰', '፱'
  ];

  static const List<String> _tens = [
    '', '፲', '፳', '፴', '፵', '፶', '፷', '፸', '፹', '፺'
  ];

  static const String _hundred = '፻';
  static const String _tenThousand = '፼';

  /// Converts an integer (1 - 10000) to Ethiopic numeral representation.
  static String toEthiopic(int number) {
    if (number <= 0) return number.toString();
    if (number > 10000) return number.toString();

    // 1 to 9
    if (number < 10) {
      return _ones[number];
    }

    // 10 to 99
    if (number < 100) {
      final ten = number ~/ 10;
      final one = number % 10;
      return '${_tens[ten]}${_ones[one]}';
    }

    // 100 to 999
    if (number < 1000) {
      final hundredDigit = number ~/ 100;
      final remainder = number % 100;
      final prefix = hundredDigit == 1 ? _hundred : '${_ones[hundredDigit]}$_hundred';
      if (remainder == 0) return prefix;
      return '$prefix${toEthiopic(remainder)}';
    }

    // 1000 to 9999
    final thousands = number ~/ 100;
    final remainder = number % 100;
    final prefix = '${toEthiopic(thousands)}$_hundred';
    if (remainder == 0) return prefix;
    return '$prefix${toEthiopic(remainder)}';
  }

  /// Converts a number formatted as: "መዝሙር ፩ (1)" or "፩"
  static String formatPsalmTitle(int number, {bool includeArabic = true}) {
    final ethiopic = toEthiopic(number);
    if (!includeArabic) return 'መዝሙር $ethiopic';
    return 'መዝሙር $ethiopic ($number)';
  }
}
