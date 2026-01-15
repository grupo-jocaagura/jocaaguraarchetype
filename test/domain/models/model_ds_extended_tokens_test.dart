import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  test('ModelDsExtendedTokens JSON round-trip', () {
    final ModelDsExtendedTokens original = ModelDsExtendedTokens();

    final Map<String, dynamic> json = original.toJson();
    for (final String k in ModelDsExtendedTokensKeys.all) {
      expect(json.containsKey(k), isTrue, reason: 'Missing key: $k');
    }

    final ModelDsExtendedTokens parsed = ModelDsExtendedTokens.fromJson(json);
    expect(parsed, equals(original));
  });
}
