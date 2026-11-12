import 'package:flutter_test/flutter_test.dart';
import 'package:my_mezmure_dawit/core/constants/ethiopic_numerals.dart';

void main() {
  group('EthiopicNumerals Converter Tests', () {
    test('Converts single digits correctly', () {
      expect(EthiopicNumerals.toEthiopic(1), '፩');
      expect(EthiopicNumerals.toEthiopic(2), '፪');
      expect(EthiopicNumerals.toEthiopic(3), '፫');
      expect(EthiopicNumerals.toEthiopic(5), '፭');
      expect(EthiopicNumerals.toEthiopic(9), '፱');
    });

    test('Converts tens correctly', () {
      expect(EthiopicNumerals.toEthiopic(10), '፲');
      expect(EthiopicNumerals.toEthiopic(20), '፳');
      expect(EthiopicNumerals.toEthiopic(23), '፳፫');
      expect(EthiopicNumerals.toEthiopic(50), '፶');
      expect(EthiopicNumerals.toEthiopic(99), '፺፱');
    });

    test('Converts hundreds correctly for the 150 Psalms', () {
      expect(EthiopicNumerals.toEthiopic(100), '፻');
      expect(EthiopicNumerals.toEthiopic(120), '፻፳');
      expect(EthiopicNumerals.toEthiopic(150), '፻፶');
    });

    test('Formats Psalm title correctly', () {
      expect(EthiopicNumerals.formatPsalmTitle(1), 'መዝሙር ፩ (1)');
      expect(EthiopicNumerals.formatPsalmTitle(23), 'መዝሙር ፳፫ (23)');
      expect(EthiopicNumerals.formatPsalmTitle(150), 'መዝሙር ፻፶ (150)');
    });
  });
}
