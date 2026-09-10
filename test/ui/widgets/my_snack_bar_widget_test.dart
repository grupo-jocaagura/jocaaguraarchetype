import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  const Size mobileSize = Size(390, 844);
  const Size desktopSize = Size(1280, 800);

  BlocResponsive mobileResp() =>
      BlocResponsive()..setSizeForTesting(mobileSize);
  BlocResponsive desktopResp() =>
      BlocResponsive()..setSizeForTesting(desktopSize);

  Future<void> pumpHost(
    WidgetTester tester, {
    required Size mediaSize,
    required BlocResponsive r,
    required Stream<AppSnack?> stream,
    bool safeArea = true,
    int? maxWidthColumns,
    bool dismissible = true,
    double elevation = 8.0,
    VoidCallback? onDismissRequested,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          // <- fuerza el tamaño que leerá setSizeFromContext
          data: MediaQueryData(size: mediaSize),
          child: Scaffold(
            body: Stack(
              children: <Widget>[
                const SizedBox.expand(),
                MySnackBarWidget(
                  responsive: r,
                  snacks: stream,
                  safeArea: safeArea,
                  maxWidthColumns: maxWidthColumns,
                  elevation: elevation,
                  dismissible: dismissible,
                  onDismissRequested: onDismissRequested,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump(); // frame inicial
  }

  testWidgets('muestra el mensaje cuando llega por el stream',
      (WidgetTester tester) async {
    final BlocResponsive r = mobileResp();
    final StreamController<AppSnack?> ctrl =
        StreamController<AppSnack?>.broadcast();

    await pumpHost(
      tester,
      mediaSize: mobileSize,
      r: r,
      stream: ctrl.stream,
    );

    ctrl.add(AppSnack.info('Saved!'));
    await tester.pumpAndSettle(const Duration(milliseconds: 250));

    expect(find.text('Saved!'), findsOneWidget);

    await ctrl.close();
  });

  testWidgets('colocación: bottom-center en mobile, top-right en desktop',
      (WidgetTester tester) async {
    // Mobile
    final BlocResponsive rMob = mobileResp();
    final StreamController<AppSnack?> mob =
        StreamController<AppSnack?>.broadcast();
    await pumpHost(
      tester,
      mediaSize: mobileSize,
      r: rMob,
      stream: mob.stream,
    );
    mob.add(AppSnack.info('Here!'));
    await tester.pumpAndSettle(const Duration(milliseconds: 250));

    final Finder txtMob = find.text('Here!');
    expect(txtMob, findsOneWidget);
    final Align mobAlign = find
        .ancestor(of: txtMob, matching: find.byType(Align))
        .evaluate()
        .last
        .widget as Align;
    expect(mobAlign.alignment, Alignment.bottomCenter);
    await mob.close();

    // Desktop
    final BlocResponsive rDesk = desktopResp();
    final StreamController<AppSnack?> desk =
        StreamController<AppSnack?>.broadcast();
    await pumpHost(
      tester,
      mediaSize: desktopSize,
      r: rDesk,
      stream: desk.stream,
    );
    desk.add(AppSnack.info('There!'));
    await tester.pumpAndSettle(const Duration(milliseconds: 250));

    final Finder txtDesk = find.text('There!');
    expect(txtDesk, findsOneWidget);
    final Align deskAlign = find
        .ancestor(of: txtDesk, matching: find.byType(Align))
        .evaluate()
        .last
        .widget as Align;
    expect(deskAlign.alignment, Alignment.topRight);
    await desk.close();
  });

  testWidgets('hace cola (controlada): A → (hide) → B',
      (WidgetTester tester) async {
    final BlocResponsive r = mobileResp();
    final StreamController<AppSnack?> ctrl =
        StreamController<AppSnack?>.broadcast();

    await pumpHost(
      tester,
      mediaSize: mobileSize,
      r: r,
      stream: ctrl.stream,
    );

    ctrl.add(AppSnack.info('A'));
    await tester.pumpAndSettle(const Duration(milliseconds: 250));
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsNothing);

    // Oculta (el padre emite null)
    ctrl.add(null);
    await tester.pumpAndSettle(const Duration(milliseconds: 250));
    expect(find.text('A'), findsNothing);

    // Muestra B
    ctrl.add(AppSnack.info('B'));
    await tester.pumpAndSettle(const Duration(milliseconds: 250));
    expect(find.text('B'), findsOneWidget);

    await ctrl.close();
  });

  testWidgets('dismissible: pulsar Close llama onDismissRequested',
      (WidgetTester tester) async {
    final BlocResponsive r = mobileResp();
    final StreamController<AppSnack?> ctrl =
        StreamController<AppSnack?>.broadcast();
    bool dismissed = false;

    await pumpHost(
      tester,
      mediaSize: mobileSize,
      r: r,
      stream: ctrl.stream,
      onDismissRequested: () => dismissed = true,
    );

    ctrl.add(AppSnack.info('Close me'));
    await tester.pumpAndSettle(const Duration(milliseconds: 250));

    expect(find.text('Close me'), findsOneWidget);
    final Finder closeBtn = find.byTooltip('Close');
    expect(closeBtn, findsOneWidget);

    await tester.tap(closeBtn);
    await tester.pump(); // procesa el callback
    expect(dismissed, isTrue);

    await ctrl.close();
  });

  testWidgets('action: pulsa acción, ejecuta callback y pide dismiss',
      (WidgetTester tester) async {
    final BlocResponsive r = mobileResp();
    final StreamController<AppSnack?> ctrl =
        StreamController<AppSnack?>.broadcast();
    int actions = 0;
    bool dismissed = false;

    await pumpHost(
      tester,
      mediaSize: mobileSize,
      r: r,
      stream: ctrl.stream,
      onDismissRequested: () => dismissed = true,
    );

    ctrl.add(
      AppSnack.success(
        'Saved with action',
        actionLabel: 'UNDO',
        onAction: () => actions++,
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 250));

    expect(find.text('Saved with action'), findsOneWidget);
    expect(find.text('UNDO'), findsOneWidget);

    await tester.tap(find.text('UNDO'));
    await tester.pump();

    expect(actions, 1);
    expect(dismissed, isTrue);

    await ctrl.close();
  });

  testWidgets('maxWidthColumns fija el maxWidth usando widthByColumns',
      (WidgetTester tester) async {
    final BlocResponsive r = desktopResp();
    final StreamController<AppSnack?> ctrl =
        StreamController<AppSnack?>.broadcast();
    const int cols = 4;

    await pumpHost(
      tester,
      mediaSize: desktopSize,
      r: r,
      stream: ctrl.stream,
      maxWidthColumns: cols,
    );

    ctrl.add(AppSnack.info('Width test'));
    await tester.pumpAndSettle(const Duration(milliseconds: 250));

    final Finder txt = find.text('Width test');
    expect(txt, findsOneWidget);

    final ConstrainedBox cbox = find
        .ancestor(of: txt, matching: find.byType(ConstrainedBox))
        .evaluate()
        .last
        .widget as ConstrainedBox;

    final double expected = r.widthByColumns(cols.clamp(1, r.columnsNumber));
    final double maxW = cbox.constraints.maxWidth;
    expect((maxW - expected).abs() < 0.001, isTrue);

    await ctrl.close();
  });

  testWidgets('factory fromStringStream: muestra el texto recibido',
      (WidgetTester tester) async {
    final BlocResponsive r = mobileResp();
    final StreamController<String> ctrl = StreamController<String>.broadcast();

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: mobileSize),
          child: Scaffold(
            body: Stack(
              children: <Widget>[
                const SizedBox.expand(),
                MySnackBarWidget.fromStringStream(
                  responsive: r,
                  toastStream: ctrl.stream,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    ctrl.add('Hola string!');
    await tester.pumpAndSettle(const Duration(milliseconds: 250));

    expect(find.text('Hola string!'), findsOneWidget);

    await ctrl.close();
  });

  testWidgets('safeArea: por defecto ON y se puede desactivar',
      (WidgetTester tester) async {
    // ON
    final BlocResponsive rOn = mobileResp();
    final StreamController<AppSnack?> on =
        StreamController<AppSnack?>.broadcast();
    await pumpHost(
      tester,
      mediaSize: mobileSize,
      r: rOn,
      stream: on.stream,
    );
    on.add(AppSnack.info('safe on'));
    await tester.pumpAndSettle(const Duration(milliseconds: 250));

    final Finder onTxt = find.text('safe on');
    expect(onTxt, findsOneWidget);
    expect(
      find.ancestor(of: onTxt, matching: find.byType(SafeArea)),
      findsOneWidget,
    );
    await on.close();

    // OFF
    final BlocResponsive rOff = mobileResp();
    final StreamController<AppSnack?> off =
        StreamController<AppSnack?>.broadcast();
    await pumpHost(
      tester,
      mediaSize: mobileSize,
      r: rOff,
      stream: off.stream,
      safeArea: false,
    );
    off.add(AppSnack.info('safe off'));
    await tester.pumpAndSettle(const Duration(milliseconds: 250));

    final Finder offTxt = find.text('safe off');
    expect(offTxt, findsOneWidget);
    expect(
      find.ancestor(of: offTxt, matching: find.byType(SafeArea)),
      findsNothing,
    );

    await off.close();
  });

  group('Fix issue 128', () {
    testWidgets(
      'Given no active notification When rendered Then Notification semantics does not exist',
      (WidgetTester tester) async {
        final StreamController<AppSnack?> controller =
            StreamController<AppSnack?>();
        addTearDown(controller.close);

        final BlocResponsive responsive = BlocResponsive();

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (BuildContext context) {
                responsive.setSizeFromContext(context);

                return Scaffold(
                  body: MySnackBarWidget(
                    responsive: responsive,
                    snacks: controller.stream,
                  ),
                );
              },
            ),
          ),
        );

        expect(
          find.bySemanticsLabel(RegExp(r'^Notification(?:\n|$)')),
          findsNothing,
        );
      },
    );
    testWidgets(
      'Given an empty legacy notification When rendered Then Notification semantics does not exist',
      (WidgetTester tester) async {
        final StreamController<String> controller = StreamController<String>();
        addTearDown(controller.close);

        final BlocResponsive responsive = BlocResponsive();

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (BuildContext context) {
                responsive.setSizeFromContext(context);

                return Scaffold(
                  body: MySnackBarWidget.fromStringStream(
                    responsive: responsive,
                    toastStream: controller.stream,
                  ),
                );
              },
            ),
          ),
        );

        controller.add('Legacy notification');
        await tester.pumpAndSettle();
        expect(
          find.bySemanticsLabel(RegExp(r'^Notification(?:\n|$)')),
          findsOneWidget,
        );

        controller.add('');
        await tester.pumpAndSettle();

        expect(
          find.bySemanticsLabel(RegExp(r'^Notification(?:\n|$)')),
          findsNothing,
        );
      },
    );
    testWidgets(
      'Given a visible notification When rendered Then it exposes a live Notification semantics region',
      (WidgetTester tester) async {
        final StreamController<AppSnack?> controller =
            StreamController<AppSnack?>();
        addTearDown(controller.close);

        final BlocResponsive responsive = BlocResponsive();

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (BuildContext context) {
                responsive.setSizeFromContext(context);

                return Scaffold(
                  body: MySnackBarWidget(
                    responsive: responsive,
                    snacks: controller.stream,
                  ),
                );
              },
            ),
          ),
        );

        controller.add(AppSnack.info('Saved'));
        await tester.pumpAndSettle();

        final Finder notification =
            find.bySemanticsLabel(RegExp(r'^Notification(?:\n|$)'));

        expect(notification, findsOneWidget);

        expect(
          tester.getSemantics(notification),
          matchesSemantics(
            label: 'Notification\nSaved',
            value: 'Saved',
            isLiveRegion: true,
          ),
        );
      },
    );
    testWidgets(
      'Given a visible notification When rendered Then its semantics bounds are smaller than the viewport',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 800);
        tester.view.devicePixelRatio = 1.0;

        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final StreamController<AppSnack?> controller =
            StreamController<AppSnack?>();
        addTearDown(controller.close);

        final BlocResponsive responsive = BlocResponsive();

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (BuildContext context) {
                responsive.setSizeFromContext(context);

                return Scaffold(
                  body: MySnackBarWidget(
                    responsive: responsive,
                    snacks: controller.stream,
                  ),
                );
              },
            ),
          ),
        );

        controller.add(AppSnack.info('Saved'));
        await tester.pumpAndSettle();

        final Finder notificationSemantics =
            find.bySemanticsLabel(RegExp(r'^Notification(?:\n|$)'));

        expect(notificationSemantics, findsOneWidget);

        final Size semanticsSize =
            tester.getSemantics(notificationSemantics).rect.size;

        expect(semanticsSize.width, lessThan(1200));
        expect(semanticsSize.height, lessThan(800));
      },
    );
    testWidgets(
      'Given a notification overlay When hidden, visible or dismissed Then outside controls remain interactive',
      (WidgetTester tester) async {
        final StreamController<AppSnack?> controller =
            StreamController<AppSnack?>();
        addTearDown(controller.close);

        final BlocResponsive responsive = BlocResponsive();
        int taps = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (BuildContext context) {
                responsive.setSizeFromContext(context);

                return Scaffold(
                  body: Stack(
                    children: <Widget>[
                      Center(
                        child: TextButton(
                          onPressed: () {
                            taps++;
                          },
                          child: const Text('Vender'),
                        ),
                      ),
                      MySnackBarWidget(
                        responsive: responsive,
                        snacks: controller.stream,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Vender'));
        await tester.pumpAndSettle();

        expect(taps, 1);

        controller.add(AppSnack.info('Saved'));
        await tester.pumpAndSettle();
        expect(
          find.bySemanticsLabel(RegExp(r'^Notification(?:\n|$)')),
          findsOneWidget,
        );
        expect(find.bySemanticsLabel('Vender'), findsOneWidget);
        await tester.tap(find.text('Vender'));
        await tester.pumpAndSettle();
        expect(taps, 2);

        controller.add(null);
        await tester.pumpAndSettle();
        expect(
          find.bySemanticsLabel(RegExp(r'^Notification(?:\n|$)')),
          findsNothing,
        );
        await tester.tap(find.text('Vender'));
        await tester.pumpAndSettle();
        expect(taps, 3);
      },
    );
    testWidgets(
      'Given a notification action When tapped Then action and dismissal callbacks run exactly once',
      (WidgetTester tester) async {
        final StreamController<AppSnack?> controller =
            StreamController<AppSnack?>();
        addTearDown(controller.close);

        final BlocResponsive responsive = BlocResponsive();
        int actions = 0;
        int dismissals = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (BuildContext context) {
                responsive.setSizeFromContext(context);

                return Scaffold(
                  body: MySnackBarWidget(
                    responsive: responsive,
                    snacks: controller.stream,
                    onDismissRequested: () {
                      dismissals++;
                    },
                  ),
                );
              },
            ),
          ),
        );

        controller.add(
          AppSnack.info(
            'Connection failed',
            actionLabel: 'Retry',
            onAction: () {
              actions++;
            },
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();

        expect(actions, 1);
        expect(dismissals, 1);
      },
    );
    testWidgets(
      'Given a dismissible notification When Close is tapped Then dismissal is requested exactly once',
      (WidgetTester tester) async {
        final StreamController<AppSnack?> controller =
            StreamController<AppSnack?>();
        addTearDown(controller.close);

        final BlocResponsive responsive = BlocResponsive();
        int dismissals = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (BuildContext context) {
                responsive.setSizeFromContext(context);

                return Scaffold(
                  body: MySnackBarWidget(
                    responsive: responsive,
                    snacks: controller.stream,
                    onDismissRequested: () {
                      dismissals++;
                    },
                  ),
                );
              },
            ),
          ),
        );

        controller.add(AppSnack.info('Saved'));
        await tester.pumpAndSettle();

        expect(
          tester.getSemantics(find.byTooltip('Close')),
          isSemantics(
            tooltip: 'Close',
            isButton: true,
            hasTapAction: true,
          ),
        );

        await tester.tap(find.byTooltip('Close'));
        await tester.pumpAndSettle();

        expect(dismissals, 1);
      },
    );
    testWidgets(
      'Given a visible notification When hidden and transition completes Then Notification semantics disappears',
      (WidgetTester tester) async {
        final StreamController<AppSnack?> controller =
            StreamController<AppSnack?>();
        addTearDown(controller.close);

        final BlocResponsive responsive = BlocResponsive();

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (BuildContext context) {
                responsive.setSizeFromContext(context);

                return Scaffold(
                  body: MySnackBarWidget(
                    responsive: responsive,
                    snacks: controller.stream,
                  ),
                );
              },
            ),
          ),
        );

        controller.add(AppSnack.info('First notification'));
        await tester.pumpAndSettle();

        expect(
          find.bySemanticsLabel(RegExp(r'^Notification(?:\n|$)')),
          findsOneWidget,
        );

        controller.add(null);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 90));
        expect(
          find.bySemanticsLabel(RegExp(r'^Notification(?:\n|$)')),
          findsOneWidget,
        );
        await tester.pump(const Duration(milliseconds: 200));

        expect(
          find.bySemanticsLabel(RegExp(r'^Notification(?:\n|$)')),
          findsNothing,
        );
        controller.add(AppSnack.info('Second notification'));
        await tester.pumpAndSettle();

        expect(
          find.bySemanticsLabel(RegExp(r'^Notification(?:\n|$)')),
          findsOneWidget,
        );

        expect(find.text('Second notification'), findsOneWidget);
      },
    );
  });
}
