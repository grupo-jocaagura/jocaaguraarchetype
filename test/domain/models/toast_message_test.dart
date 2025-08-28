import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('ToastMessage · construcción & fábrica', () {
    test('empty() crea sentinela con texto vacío y epoch UTC', () {
      final ToastMessage t = ToastMessage.empty();
      expect(t.text, isEmpty);
      expect(t.isEmpty, isTrue);
      expect(t.isNotEmpty, isFalse);
      // Epoch (0) en milisegundos
      expect(t.at.millisecondsSinceEpoch, 0);
      // Debe ser UTC:
      expect(t.at.isUtc, isTrue);
    });

    test('constructor normal establece texto y fecha', () {
      final DateTime now = DateTime.now().toUtc();
      final ToastMessage t = ToastMessage('hola', now);
      expect(t.text, 'hola');
      expect(t.at.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
      expect(t.isNotEmpty, isTrue);
    });
  });

  group('ToastMessage · igualdad & hashCode', () {
    test('== verdadero si texto y timestamp (en ms) coinciden', () {
      final DateTime stamp =
          DateTime.fromMillisecondsSinceEpoch(123456, isUtc: true);
      final ToastMessage a = ToastMessage('hi', stamp);
      final ToastMessage b = ToastMessage('hi', stamp);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('== falso si cambia SOLO el texto', () {
      final DateTime stamp =
          DateTime.fromMillisecondsSinceEpoch(777, isUtc: true);
      final ToastMessage a = ToastMessage('A', stamp);
      final ToastMessage b = ToastMessage('B', stamp);

      expect(a == b, isFalse);
    });

    test('== falso si cambia SOLO el timestamp (1 ms)', () {
      final DateTime t0 =
          DateTime.fromMillisecondsSinceEpoch(1000, isUtc: true);
      final DateTime t1 =
          DateTime.fromMillisecondsSinceEpoch(1001, isUtc: true);
      final ToastMessage a = ToastMessage('same', t0);
      final ToastMessage b = ToastMessage('same', t1);

      expect(a == b, isFalse);
    });
  });

  group('ToastMessage · copyWith & (in)mutabilidad', () {
    test('copyWith sin argumentos conserva valores', () {
      final DateTime stamp =
          DateTime.fromMillisecondsSinceEpoch(42, isUtc: true);
      final ToastMessage a = ToastMessage('x', stamp);
      final ToastMessage c = a.copyWith();

      expect(c, equals(a));
      expect(
        identical(c, a),
        isFalse,
        reason: 'Debe crear una nueva instancia',
      );
    });

    test('copyWith(text) cambia solo el texto', () {
      final DateTime stamp =
          DateTime.fromMillisecondsSinceEpoch(42, isUtc: true);
      final ToastMessage a = ToastMessage('x', stamp);
      final ToastMessage c = a.copyWith(text: 'y');

      expect(c.text, 'y');
      expect(c.at.millisecondsSinceEpoch, a.at.millisecondsSinceEpoch);
      // El original permanece igual
      expect(a.text, 'x');
    });

    test('copyWith(at) cambia solo el timestamp', () {
      final DateTime t0 = DateTime.fromMillisecondsSinceEpoch(10, isUtc: true);
      final DateTime t1 = DateTime.fromMillisecondsSinceEpoch(99, isUtc: true);
      final ToastMessage a = ToastMessage('msg', t0);
      final ToastMessage c = a.copyWith(at: t1);

      expect(c.text, 'msg');
      expect(c.at.millisecondsSinceEpoch, t1.millisecondsSinceEpoch);
      expect(a.at.millisecondsSinceEpoch, t0.millisecondsSinceEpoch);
    });
  });

  group('ToastMessage · helpers isEmpty / isNotEmpty', () {
    test('isEmpty/isNotEmpty coherentes', () {
      final ToastMessage empty = ToastMessage.empty();
      final ToastMessage full = ToastMessage(
        'not empty',
        DateTime.fromMillisecondsSinceEpoch(1, isUtc: true),
      );

      expect(empty.isEmpty, isTrue);
      expect(empty.isNotEmpty, isFalse);

      expect(full.isEmpty, isFalse);
      expect(full.isNotEmpty, isTrue);
    });
  });
}
