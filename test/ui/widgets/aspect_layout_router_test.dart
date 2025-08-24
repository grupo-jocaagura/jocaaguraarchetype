import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  group('AspectLayoutRouter.routeFor', () {
    const double t = 0.08; // snapTolerance por defecto

    test('Snap exactos 1:1, 2:1, 3:1', () {
      expect(AspectLayoutRouter.routeFor(1.0, t), AspectRoute.square);
      expect(AspectLayoutRouter.routeFor(2.0, t), AspectRoute.wide2x1);
      expect(AspectLayoutRouter.routeFor(3.0, t), AspectRoute.wide3x1);
    });

    test('Snap por tolerancia cercanos a exactos', () {
      expect(AspectLayoutRouter.routeFor(1.06, t), AspectRoute.square);
      expect(AspectLayoutRouter.routeFor(0.94, t), AspectRoute.square);

      expect(AspectLayoutRouter.routeFor(1.94, t), AspectRoute.wide2x1);
      expect(AspectLayoutRouter.routeFor(2.06, t), AspectRoute.wide2x1);

      expect(AspectLayoutRouter.routeFor(2.94, t), AspectRoute.wide3x1);
      expect(AspectLayoutRouter.routeFor(3.06, t), AspectRoute.wide3x1);
    });

    test('Genéricos horizontal / vertical', () {
      expect(AspectLayoutRouter.routeFor(1.3, t), AspectRoute.horizontal);
      expect(AspectLayoutRouter.routeFor(0.7, t), AspectRoute.vertical);
    });
  });
}
