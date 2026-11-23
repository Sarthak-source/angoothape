import 'package:angoothape/core/utils/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sample Aadhaar passes Verhoeff', () {
    final id = sampleAadhaar();
    expect(id.length, 12);
    expect(looksLikeAadhaar(id), isTrue);
    expect(verhoeffOk(id), isTrue);
    final flipped = '${id[0] == '2' ? '3' : '2'}${id.substring(1)}';
    expect(verhoeffOk(flipped), isFalse);
  });

  test('amount grouping uses Indian commas', () {
    expect(groupIn(18450), '18,450.00');
    expect(inr(6500, dec: 0), '₹6,500');
  });

  test('mobile and amount limits', () {
    expect(validMobile('9876543210'), isTrue);
    expect(validMobile('5876543210'), isFalse);
  });
}
