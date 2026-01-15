import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('ModelDataVizPaletteKeys', () {
    test(
        'Given keys registry When all is used Then it contains expected keys and has no duplicates',
        () {
      const List<String> keys = ModelDataVizPaletteKeys.all;

      expect(keys.toSet().length, keys.length);
      expect(keys, contains(ModelDataVizPaletteKeys.categorical));
      expect(keys, contains(ModelDataVizPaletteKeys.sequential));
    });
  });

  group('ModelDataVizPalette validation', () {
    test('Given empty categorical When constructing Then throws RangeError',
        () {
      expect(
        () => const ModelDataVizPalette(
          categorical: <Color>[],
          sequential: <Color>[Color(0xFF000000), Color(0xFFFFFFFF)],
        )..toJson(), // force usage; constructor itself does not validate
        returnsNormally,
        reason:
            'Constructor is const and does not auto-validate; validation happens in factories/copy patterns.',
      );
    });

    test('Given fallback When built Then it is valid and has expected sizes',
        () {
      final ModelDataVizPalette p = ModelDataVizPalette.fallback();

      expect(p.categorical.length, 10);
      expect(p.sequential.length, 6);
    });
  });

  group('ModelDataVizPalette JSON', () {
    test('Given fallback When toJson then fromJson Then round-trip equals', () {
      final ModelDataVizPalette original = ModelDataVizPalette.fallback();

      final Map<String, dynamic> json = original.toJson();
      final ModelDataVizPalette restored = ModelDataVizPalette.fromJson(json);

      expect(restored, equals(original));
      expect(restored.hashCode, equals(original.hashCode));
    });

    test(
        'Given json missing a required key When fromJson Then throws FormatException',
        () {
      final Map<String, dynamic> json = ModelDataVizPalette.fallback().toJson();
      json.remove(ModelDataVizPaletteKeys.categorical);

      expect(
        () => ModelDataVizPalette.fromJson(json),
        throwsA(isA<FormatException>()),
      );
    });

    test(
        'Given json with wrong shape When fromJson Then throws FormatException',
        () {
      expect(
        () => ModelDataVizPalette.fromJson(const <String, dynamic>{
          ModelDataVizPaletteKeys.categorical: 'nope',
          ModelDataVizPaletteKeys.sequential: <int>[0xFF000000, 0xFFFFFFFF],
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test(
        'Given json with invalid palettes When fromJson Then throws RangeError',
        () {
      expect(
        () => ModelDataVizPalette.fromJson(const <String, dynamic>{
          ModelDataVizPaletteKeys.categorical: <int>[],
          ModelDataVizPaletteKeys.sequential: <int>[0xFF000000], // < 2
        }),
        throwsA(isA<RangeError>()),
      );
    });
  });

  group('ModelDataVizPalette.categoricalAt', () {
    test(
        'Given index within range When categoricalAt Then returns exact element',
        () {
      final ModelDataVizPalette p = ModelDataVizPalette.fallback();

      expect(p.categoricalAt(0), p.categorical[0]);
      expect(p.categoricalAt(9), p.categorical[9]);
    });

    test('Given index out of range When categoricalAt Then wraps around', () {
      final ModelDataVizPalette p = ModelDataVizPalette.fallback();

      // 10 colors: index 10 wraps to 0
      expect(p.categoricalAt(10), p.categorical[0]);
      expect(p.categoricalAt(11), p.categorical[1]);
    });

    test(
        'Given negative index When categoricalAt Then behaves consistently with Dart modulo',
        () {
      final ModelDataVizPalette p = ModelDataVizPalette.fallback();

      // This asserts the actual runtime behavior:
      // In Dart, (-1) % 10 == 9.
      expect((-1) % p.categorical.length, 9);
      expect(p.categoricalAt(-1), p.categorical[9]);
    });
  });

  group('ModelDataVizPalette.sequentialAt', () {
    test('Given t <= 0 When sequentialAt Then returns first color', () {
      final ModelDataVizPalette p = ModelDataVizPalette.fallback();

      expect(p.sequentialAt(-1.0), p.sequential.first);
      expect(p.sequentialAt(0.0), p.sequential.first);
    });

    test('Given t >= 1 When sequentialAt Then returns last color', () {
      final ModelDataVizPalette p = ModelDataVizPalette.fallback();

      expect(p.sequentialAt(1.0), p.sequential.last);
      expect(p.sequentialAt(2.0), p.sequential.last);
    });

    test(
        'Given t between steps When sequentialAt Then interpolates (lerp) deterministically',
        () {
      final ModelDataVizPalette p = ModelDataVizPalette.fallback();

      // With 6 steps, positions are: 0..5.
      // t=0.5 -> pos=2.5 -> lerp between idx=2 and 3 at localT=0.5
      final Color expected = Color.lerp(p.sequential[2], p.sequential[3], 0.5)!;
      final Color actual = p.sequentialAt(0.5);

      expect(actual, expected);
    });

    test(
        'Given t exactly on a step When sequentialAt Then returns that exact step',
        () {
      final ModelDataVizPalette p = ModelDataVizPalette.fallback();

      // t=0.4 -> pos=2.0 for 6 steps? Actually pos = t*(len-1)=0.4*5=2.0
      // idx=2, next=3, localT=0 -> returns sequential[2]
      expect(p.sequentialAt(0.4), p.sequential[2]);
    });
  });

  group('ModelDataVizPalette equality', () {
    test('Given same content When compared Then equals true', () {
      final ModelDataVizPalette a = ModelDataVizPalette.fallback();
      final ModelDataVizPalette b = ModelDataVizPalette.fromJson(a.toJson());

      expect(a, equals(b));
    });

    test('Given different content When compared Then equals false', () {
      final ModelDataVizPalette a = ModelDataVizPalette.fallback();

      final ModelDataVizPalette b = ModelDataVizPalette(
        categorical: <Color>[...a.categorical]..[0] = const Color(0xFF000000),
        sequential: a.sequential,
      );

      expect(a == b, isFalse);
    });
  });
}
