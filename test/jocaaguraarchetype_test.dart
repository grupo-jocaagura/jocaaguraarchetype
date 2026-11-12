import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

// revisado 10/03/2024 @albertjjimenezp

void main() {
  test('adds one to input values', () {
    final JocaaguraArchetype calculator = JocaaguraArchetype();
    expect(calculator.addOne(2), 3);
    expect(calculator.addOne(-7), -6);
    expect(calculator.addOne(0), 1);
  });

  testWidgets('testMe completes after two seconds', (
    WidgetTester tester,
  ) async {
    final JocaaguraArchetype jocaaguraArchetype = JocaaguraArchetype();
    bool completed = false;
    final Future<void> task = jocaaguraArchetype.testMe().then((_) {
      completed = true;
    });

    await tester.pump(const Duration(milliseconds: 1999));
    expect(completed, isFalse);
    await tester.pump(const Duration(milliseconds: 1));
    await task;
    expect(completed, isTrue);
  });
}
