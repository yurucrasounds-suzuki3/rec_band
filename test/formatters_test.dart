import 'package:flutter_test/flutter_test.dart';
import 'package:rec_band/utils/formatters.dart';

void main() {
  test('formatDateTime returns fallback when null', () {
    expect(formatDateTime(null), 'たった今');
  });
}
