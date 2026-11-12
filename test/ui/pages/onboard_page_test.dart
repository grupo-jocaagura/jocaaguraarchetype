import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:material_ui/material_ui.dart';

/// ------------------------------------------------------------
/// Fake muy pequeño para probar OnBoardingPage en aislamiento.
/// - Emite en `stateStream` cuando cambia el "step".
/// - Expone `currentStep` con un título.
/// ------------------------------------------------------------
class _FakeOnboardingBloc extends BlocOnboarding {
  _FakeOnboardingBloc();

  final StreamController<OnboardingState> _ctrl =
      StreamController<OnboardingState>.broadcast();

  OnboardingStep? _current;

  /// 👇 Si prefieres tiparlo exactamente como el real:
  /// change: return type -> Stream<OnboardingState>
  @override
  Stream<OnboardingState> get stateStream => _ctrl.stream;

  /// 👇 Debe devolver el tipo real del dominio.
  @override
  OnboardingStep? get currentStep => _current;

  /// Cambia el step actual y emite un estado para que el StreamBuilder haga rebuild.
  void setStepTitle(String title) {
    // ⚠️ Ajusta si tu OnboardingStep tiene firma distinta:
    _current = OnboardingStep(title: title);

    // ⚠️ Ajusta si tu OnboardingState requiere datos específicos:
    _ctrl.add(OnboardingState.idle());
  }

  @override
  Future<void> dispose() async {
    await _ctrl.close();
  }
}

/// ------------------------------------------------------------
/// Helpers
/// ------------------------------------------------------------
Future<void> _pump(
  WidgetTester tester, {
  required _FakeOnboardingBloc bloc,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: OnBoardingPage(blocOnboarding: bloc /* BlocOnboarding */),
    ),
  );
  await tester.pump(); // primer frame
}

void main() {
  group('OnBoardingPage', () {
    testWidgets('muestra "Loading..." inicialmente (sin currentStep)', (
      WidgetTester tester,
    ) async {
      final _FakeOnboardingBloc bloc = _FakeOnboardingBloc();
      await _pump(tester, bloc: bloc);

      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await bloc.dispose();
    });

    testWidgets('renderiza el título del currentStep al emitir en el stream', (
      WidgetTester tester,
    ) async {
      final _FakeOnboardingBloc bloc = _FakeOnboardingBloc();
      await _pump(tester, bloc: bloc);

      // Emite un step con título
      bloc.setStepTitle('Bienvenido');
      await tester.pump(); // rebuild del StreamBuilder

      expect(find.text('Bienvenido'), findsOneWidget);
      expect(find.text('Loading...'), findsNothing);

      await bloc.dispose();
    });

    testWidgets('actualiza el título cuando cambia el step', (
      WidgetTester tester,
    ) async {
      final _FakeOnboardingBloc bloc = _FakeOnboardingBloc();
      await _pump(tester, bloc: bloc);

      bloc.setStepTitle('Paso 1');
      await tester.pump();
      expect(find.text('Paso 1'), findsOneWidget);

      bloc.setStepTitle('Paso 2');
      await tester.pump();
      expect(find.text('Paso 2'), findsOneWidget);
      expect(find.text('Paso 1'), findsNothing);

      await bloc.dispose();
    });

    testWidgets(
      'cuando se cierra el stream, conserva el último título pintado',
      (WidgetTester tester) async {
        final _FakeOnboardingBloc bloc = _FakeOnboardingBloc();
        await _pump(tester, bloc: bloc);

        bloc.setStepTitle('Último');
        await tester.pump();

        // Cierra el stream
        await bloc.dispose();
        await tester.pump();

        // Sigue mostrándose el último texto (el widget no crashea)
        expect(find.text('Último'), findsOneWidget);
      },
    );

    testWidgets('layout básico: texto centrado y ocupa ancho completo', (
      WidgetTester tester,
    ) async {
      final _FakeOnboardingBloc bloc = _FakeOnboardingBloc();
      await _pump(tester, bloc: bloc);

      // Por contrato del widget tenemos un Text con textAlign.center
      final Text t = tester.widget<Text>(find.byType(Text).first);
      expect(t.textAlign, TextAlign.center);

      // Hay un SizedBox que debería expandirse a el ancho
      expect(find.byType(SizedBox), findsWidgets);

      await bloc.dispose();
    });
  });
}
