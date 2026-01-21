import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('FlowConstraintUtils.formatUrl', () {
    test(
        'Given label/url valid When format Then returns normalized url constraint',
        () {
      // Arrange
      final Uri url = Uri.parse('https://example.com/docs');

      // Act
      final String c =
          FlowConstraintUtils.formatUrl(label: '  Figma  ', url: url);

      // Assert
      expect(c, 'url:figma|https://example.com/docs');
    });

    test('Given empty label When format Then returns url:unknown|', () {
      final String c = FlowConstraintUtils.formatUrl(
        label: '   ',
        url: Uri.parse('https://example.com'),
      );
      expect(c, 'url:unknown|');
    });

    test('Given empty url string When format Then returns url:unknown|', () {
      // Uri.parse('') produce Uri vacía; toString() -> ''.
      final String c = FlowConstraintUtils.formatUrl(
        label: 'docs',
        url: Uri.parse(''),
      );
      expect(c, 'url:unknown|');
    });
  });

  group('FlowConstraintUtils.formatMetric', () {
    test(
        'Given finite value When format Then returns normalized metric constraint',
        () {
      final String c = FlowConstraintUtils.formatMetric(
        name: ' Sugar ',
        value: 2,
        unit: ' TbSp ',
      );
      expect(c, 'metric:sugar|2.0|tbsp');
    });

    test('Given NaN When format Then value normalizes to 0.0', () {
      final String c = FlowConstraintUtils.formatMetric(
        name: 'latency',
        value: double.nan,
        unit: 'ms',
      );
      expect(c, 'metric:latency|0.0|ms');
    });

    test('Given Infinity When format Then value normalizes to 0.0', () {
      final String c = FlowConstraintUtils.formatMetric(
        name: 'latency',
        value: double.infinity,
        unit: 'ms',
      );
      expect(c, 'metric:latency|0.0|ms');
    });
  });

  group('FlowConstraintUtils.parse', () {
    test('Given empty raw When parse Then returns unknown with empty raw', () {
      final FlowConstraint c = FlowConstraintUtils.parse('   ');
      expect(c.kind, FlowConstraintKind.unknown);
      expect(c.raw, '');
    });

    test(
        'Given url constraint When parse Then returns url kind with label and uri',
        () {
      final FlowConstraint c =
          FlowConstraintUtils.parse('url:figma|https://example.com/a');
      expect(c.kind, FlowConstraintKind.url);
      expect(c.label, 'figma');
      expect(c.url, isNotNull);
      expect(c.url.toString(), 'https://example.com/a');
    });

    test(
        'Given url constraint with missing url When parse Then url may be null or empty uri but kind is url',
        () {
      final FlowConstraint c = FlowConstraintUtils.parse('url:docs|');
      expect(c.kind, FlowConstraintKind.url);
      expect(c.label, 'docs');
      // Aceptamos ambos comportamientos: null o Uri vacía.
      // Lo importante: la UI debe tratarlo como "no navegable".
      expect(c.url == null || c.url.toString().isEmpty, isTrue);
    });

    test(
        'Given metric constraint When parse Then returns metric kind with fields',
        () {
      final FlowConstraint c = FlowConstraintUtils.parse('metric:sugar|2|tbsp');
      expect(c.kind, FlowConstraintKind.metric);
      expect(c.key, 'sugar');
      expect(c.value, 2.0);
      expect(c.unit, 'tbsp');
    });

    test(
        'Given metric constraint with non-numeric value When parse Then value is null',
        () {
      final FlowConstraint c =
          FlowConstraintUtils.parse('metric:sugar|two|tbsp');
      expect(c.kind, FlowConstraintKind.metric);
      expect(c.key, 'sugar');
      expect(c.value, isNull);
      expect(c.unit, 'tbsp');
    });

    test('Given flag constraint When parse Then returns flag with key', () {
      final FlowConstraint c =
          FlowConstraintUtils.parse('flag:requiresInternet');
      expect(c.kind, FlowConstraintKind.flag);
      expect(c.key, 'requiresInternet');
    });

    test('Given legacy flag (no prefix) When parse Then treated as flag', () {
      final FlowConstraint c = FlowConstraintUtils.parse('requiresInternet');
      expect(c.kind, FlowConstraintKind.flag);
      expect(c.key, 'requiresInternet');
      expect(c.raw, 'requiresInternet');
    });
  });

  group('FlowConstraintUtils.containsExact', () {
    test('Given list contains exact When containsExact Then true', () {
      final List<String> constraints = <String>['a', 'b'];
      final bool result = FlowConstraintUtils.containsExact(
        constraints: constraints,
        raw: 'b',
      );
      expect(result, isTrue);
    });

    test('Given list does not contain exact When containsExact Then false', () {
      final List<String> constraints = <String>['a', 'b'];
      final bool result = FlowConstraintUtils.containsExact(
        constraints: constraints,
        raw: 'B', // distinto
      );
      expect(result, isFalse);
    });
  });

  group('ModelFlowStepConstraintsX', () {
    ModelFlowStep makeStep({List<String> constraints = const <String>[]}) {
      return ModelFlowStep.immutable(
        index: 1,
        title: 'Step',
        description: 'Desc',
        failureCode: 'FAIL',
        nextOnSuccessIndex: -1,
        nextOnFailureIndex: -1,
        constraints: constraints,
      );
    }

    test('Given no existing url constraint When withUrlConstraint Then adds it',
        () {
      final ModelFlowStep step = makeStep();
      final ModelFlowStep updated = step.withUrlConstraint(
        label: 'docs',
        url: Uri.parse('https://example.com/docs'),
      );

      expect(step.constraints, isEmpty);
      expect(updated.constraints.length, 1);
      expect(updated.constraints.first, 'url:docs|https://example.com/docs');
    });

    test(
        'Given existing exact url constraint When withUrlConstraint Then does not duplicate',
        () {
      final ModelFlowStep step = makeStep(
        constraints: <String>['url:docs|https://example.com/docs'],
      );

      final ModelFlowStep updated = step.withUrlConstraint(
        label: 'docs',
        url: Uri.parse('https://example.com/docs'),
      );

      expect(updated.constraints.length, 1);
    });

    test(
        'Given metric constraint When withMetricConstraint Then adds it and stays deeply immutable',
        () {
      final ModelFlowStep step = makeStep();
      final ModelFlowStep updated = step.withMetricConstraint(
        name: 'sugar',
        value: 2,
        unit: 'tbsp',
      );

      expect(updated.constraints, <String>['metric:sugar|2.0|tbsp']);

      // Deep immutability contract from ModelFlowStep.immutable/copyWith
      expect(() => updated.constraints.add('x'), throwsUnsupportedError);
    });
  });
  group('FlowConstraint.isNavigableUrl', () {
    test('Given https absolute URL When parsed Then isNavigableUrl is true',
        () {
      // Arrange
      const String raw = 'url:docs|https://example.com/a';

      // Act
      final FlowConstraint c = FlowConstraintUtils.parse(raw);

      // Assert
      expect(c.kind, FlowConstraintKind.url);
      expect(c.isNavigableUrl, isTrue);
      expect(c.url, isNotNull);
      expect(c.url.toString(), 'https://example.com/a');
    });

    test(
        'Given http absolute URL When parsed Then isNavigableUrl is false (https-only)',
        () {
      final FlowConstraint c =
          FlowConstraintUtils.parse('url:docs|http://example.com/a');

      expect(c.kind, FlowConstraintKind.url);
      expect(c.url, isNotNull);
      expect(c.isNavigableUrl, isFalse);
    });

    test('Given missing URL part When parsed Then isNavigableUrl is false', () {
      // urlStr = '' -> Uri.tryParse('') suele dar Uri vacía o null según entrada.
      final FlowConstraint c = FlowConstraintUtils.parse('url:docs|');

      expect(c.kind, FlowConstraintKind.url);
      expect(c.isNavigableUrl, isFalse);
    });

    test('Given relative URL When parsed Then isNavigableUrl is false', () {
      final FlowConstraint c = FlowConstraintUtils.parse('url:docs|/path');

      expect(c.kind, FlowConstraintKind.url);
      // Puede parsear a Uri, pero no es absoluta.
      expect(c.isNavigableUrl, isFalse);
    });

    test('Given URL without scheme When parsed Then isNavigableUrl is false',
        () {
      final FlowConstraint c =
          FlowConstraintUtils.parse('url:docs|example.com/a');

      expect(c.kind, FlowConstraintKind.url);
      // Puede parsear como Uri relativa (path), pero sin scheme.
      expect(c.isNavigableUrl, isFalse);
    });

    test('Given non-url constraint When evaluated Then isNavigableUrl is false',
        () {
      final FlowConstraint metric =
          FlowConstraintUtils.parse('metric:sugar|2|tbsp');
      final FlowConstraint flag =
          FlowConstraintUtils.parse('requiresInternet'); // legacy

      expect(metric.kind, FlowConstraintKind.metric);
      expect(metric.isNavigableUrl, isFalse);

      expect(flag.kind, FlowConstraintKind.flag);
      expect(flag.isNavigableUrl, isFalse);
    });

    test(
        'Given URL with leading/trailing spaces When parsed Then trimming still allows navigation',
        () {
      final FlowConstraint c =
          FlowConstraintUtils.parse('  url:docs|https://example.com/a  ');

      expect(c.kind, FlowConstraintKind.url);
      expect(c.isNavigableUrl, isTrue);
      expect(c.url.toString(), 'https://example.com/a');
    });
  });
  group('FlowConstraint.isNavigableUrl roundtrip', () {
    test('Given formatUrl https When parse Then isNavigableUrl true', () {
      final String raw = FlowConstraintUtils.formatUrl(
        label: 'Docs',
        url: Uri.parse('https://example.com/docs'),
      );

      final FlowConstraint c = FlowConstraintUtils.parse(raw);

      expect(raw, 'url:docs|https://example.com/docs');
      expect(c.isNavigableUrl, isTrue);
    });

    test(
        'Given formatUrl with empty label When parse Then isNavigableUrl false',
        () {
      final String raw = FlowConstraintUtils.formatUrl(
        label: '   ',
        url: Uri.parse('https://example.com/docs'),
      );

      final FlowConstraint c = FlowConstraintUtils.parse(raw);

      // raw == url:unknown|
      expect(c.kind, FlowConstraintKind.url);
      expect(c.isNavigableUrl, isFalse);
    });
  });
}
