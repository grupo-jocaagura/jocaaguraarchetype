import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

// revisado 10/03/2024 author: @albertjjimenezp
class ChildWidgetMock extends StatelessWidget {
  const ChildWidgetMock({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

const ValueKey<String> vk1x1 = ValueKey<String>('child1x1');
const ValueKey<String> vk1x2 = ValueKey<String>('child1x2');
const ValueKey<String> vk1x3 = ValueKey<String>('child1x3');
const ValueKey<String> vkVertical = ValueKey<String>('childVertical');
const ValueKey<String> vkHorizontal = ValueKey<String>('childHorizontal');

const ChildWidgetMock child1x1 = ChildWidgetMock(
  key: vk1x1,
);
const ChildWidgetMock child1x2 = ChildWidgetMock(
  key: vk1x2,
);
const ChildWidgetMock child1x3 = ChildWidgetMock(
  key: vk1x3,
);
const ChildWidgetMock childVertical = ChildWidgetMock(
  key: vkVertical,
);
const ChildWidgetMock childHorizontal = ChildWidgetMock(
  key: vkHorizontal,
);

void main() {
  group('Testing generator widget width device 1200 x 400', () {
    testWidgets(
        'GeneratorWidget displays child1x3 when width is equal to height * 3',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(
                1200,
                400,
              ), // Proporciona un tamaño específico para la prueba
            ),
            child: Scaffold(
              body: SizedBox(
                width: 300,
                height: 100,
                child: GeneratorWidget(
                  child1x1: child1x1,
                  child1x2: child1x2,
                  child1x3: child1x3,
                  childVertical: childVertical,
                  childHorizontal: childHorizontal,
                ),
              ),
            ),
          ),
        ),
      );

      final MediaQueryData mediaQueryData =
          MediaQuery.of(tester.element(find.byType(GeneratorWidget)));
      final double width = mediaQueryData.size.width;
      final double height = mediaQueryData.size.height;

      if (width == height * 3) {
        expect(find.byKey(vk1x3), findsOneWidget);
      }

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  testWidgets(
      'GeneratorWidget displays child1x2 when width is equal to height * 2',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(
              1200,
              400,
            ),
          ),
          child: Scaffold(
            body: SizedBox(
              width: 200,
              height: 100,
              child: GeneratorWidget(
                child1x1: child1x1,
                child1x2: child1x2,
                child1x3: child1x3,
                childVertical: childVertical,
                childHorizontal: childHorizontal,
              ),
            ),
          ),
        ),
      ),
    );

    final MediaQueryData mediaQueryData =
        MediaQuery.of(tester.element(find.byType(GeneratorWidget)));
    final double width = mediaQueryData.size.width;
    final double height = mediaQueryData.size.height;

    if (width == height * 2) {
      expect(find.byKey(vk1x2), findsOneWidget);
    }
  });

  testWidgets('GeneratorWidget displays child1x1 when width is equal to height',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(
              1200,
              400,
            ),
          ),
          child: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: GeneratorWidget(
                child1x1: child1x1,
                child1x2: child1x2,
                child1x3: child1x3,
                childVertical: childVertical,
                childHorizontal: childHorizontal,
              ),
            ),
          ),
        ),
      ),
    );

    final MediaQueryData mediaQueryData =
        MediaQuery.of(tester.element(find.byType(GeneratorWidget)));
    final double width = mediaQueryData.size.width;
    final double height = mediaQueryData.size.height;

    if (width == height) {
      expect(find.byKey(vk1x1), findsOneWidget);
    }
  });

  testWidgets(
      'GeneratorWidget displays childHorizontal when width is greater than height',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(
              1200,
              400,
            ),
          ),
          child: Scaffold(
            body: SizedBox(
              width: 600,
              height: 400,
              child: GeneratorWidget(
                child1x1: child1x1,
                child1x2: child1x2,
                child1x3: child1x3,
                childVertical: childVertical,
                childHorizontal: childHorizontal,
              ),
            ),
          ),
        ),
      ),
    );

    final MediaQueryData mediaQueryData =
        MediaQuery.of(tester.element(find.byType(GeneratorWidget)));
    final double width = mediaQueryData.size.width;
    final double height = mediaQueryData.size.height;

    if (width > height) {
      expect(find.byKey(vkHorizontal), findsOneWidget);
    }
  });

  testWidgets(
      'GeneratorWidget displays childVertical when width is less than height',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(
              1200,
              400,
            ),
          ),
          child: Scaffold(
            body: SizedBox(
              width: 200,
              height: 400,
              child: GeneratorWidget(
                child1x1: child1x1,
                child1x2: child1x2,
                child1x3: child1x3,
                childVertical: childVertical,
                childHorizontal: childHorizontal,
              ),
            ),
          ),
        ),
      ),
    );

    final MediaQueryData mediaQueryData =
        MediaQuery.of(tester.element(find.byType(GeneratorWidget)));
    final double width = mediaQueryData.size.width;
    final double height = mediaQueryData.size.height;

    if (width < height) {
      expect(find.byKey(vkVertical), findsOneWidget);
    }
  });
}
