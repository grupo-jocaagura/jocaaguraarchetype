import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// ======= Tus esquemas de color + seed =======
const Color seed = Color(0xff8e4d2f);

const ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xff8e4d2f),
  surfaceTint: Color(0xff8e4d2f),
  onPrimary: Color(0xffffffff),
  primaryContainer: Color(0xffffdbcd),
  onPrimaryContainer: Color(0xff71361a),
  secondary: Color(0xff725c0c),
  onSecondary: Color(0xffffffff),
  secondaryContainer: Color(0xffffe088),
  onSecondaryContainer: Color(0xff574500),
  tertiary: Color(0xff7f4d7a),
  onTertiary: Color(0xffffffff),
  tertiaryContainer: Color(0xffffd7f6),
  onTertiaryContainer: Color(0xff653661),
  error: Color(0xff904a43),
  onError: Color(0xffffffff),
  errorContainer: Color(0xffffdad6),
  onErrorContainer: Color(0xff73332d),
  surface: Color(0xfff5fafb),
  onSurface: Color(0xff171d1e),
  onSurfaceVariant: Color(0xff3f484a),
  outline: Color(0xff6f797a),
  outlineVariant: Color(0xffbfc8ca),
  shadow: Color(0xff000000),
  scrim: Color(0xff000000),
  inverseSurface: Color(0xff2b3133),
  inversePrimary: Color(0xffffb596),
  primaryFixed: Color(0xffffdbcd),
  onPrimaryFixed: Color(0xff360f00),
  primaryFixedDim: Color(0xffffb596),
  onPrimaryFixedVariant: Color(0xff71361a),
  secondaryFixed: Color(0xffffe088),
  onSecondaryFixed: Color(0xff241a00),
  secondaryFixedDim: Color(0xffe2c46d),
  onSecondaryFixedVariant: Color(0xff574500),
  tertiaryFixed: Color(0xffffd7f6),
  onTertiaryFixed: Color(0xff330833),
  tertiaryFixedDim: Color(0xfff1b3e7),
  onTertiaryFixedVariant: Color(0xff653661),
  surfaceDim: Color(0xffd5dbdc),
  surfaceBright: Color(0xfff5fafb),
  surfaceContainerLowest: Color(0xffffffff),
  surfaceContainerLow: Color(0xffeff5f6),
  surfaceContainer: Color(0xffe9eff0),
  surfaceContainerHigh: Color(0xffe3e9ea),
  surfaceContainerHighest: Color(0xffdee3e5),
);

const ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xffffb596),
  surfaceTint: Color(0xffffb596),
  onPrimary: Color(0xff542106),
  primaryContainer: Color(0xff71361a),
  onPrimaryContainer: Color(0xffffdbcd),
  secondary: Color(0xffe2c46d),
  onSecondary: Color(0xff3c2f00),
  secondaryContainer: Color(0xff574500),
  onSecondaryContainer: Color(0xffffe088),
  tertiary: Color(0xfff1b3e7),
  onTertiary: Color(0xff4c1f49),
  tertiaryContainer: Color(0xff653661),
  onTertiaryContainer: Color(0xffffd7f6),
  error: Color(0xffffb4ab),
  onError: Color(0xff561e19),
  errorContainer: Color(0xff73332d),
  onErrorContainer: Color(0xffffdad6),
  surface: Color(0xff0e1415),
  onSurface: Color(0xffdee3e5),
  onSurfaceVariant: Color(0xffbfc8ca),
  outline: Color(0xff899294),
  outlineVariant: Color(0xff3f484a),
  shadow: Color(0xff000000),
  scrim: Color(0xff000000),
  inverseSurface: Color(0xffdee3e5),
  inversePrimary: Color(0xff8e4d2f),
  primaryFixed: Color(0xffffdbcd),
  onPrimaryFixed: Color(0xff360f00),
  primaryFixedDim: Color(0xffffb596),
  onPrimaryFixedVariant: Color(0xff71361a),
  secondaryFixed: Color(0xffffe088),
  onSecondaryFixed: Color(0xff241a00),
  secondaryFixedDim: Color(0xffe2c46d),
  onSecondaryFixedVariant: Color(0xff574500),
  tertiaryFixed: Color(0xffffd7f6),
  onTertiaryFixed: Color(0xff330833),
  tertiaryFixedDim: Color(0xfff1b3e7),
  onTertiaryFixedVariant: Color(0xff653661),
  surfaceDim: Color(0xff0e1415),
  surfaceBright: Color(0xff343a3b),
  surfaceContainerLowest: Color(0xff090f10),
  surfaceContainerLow: Color(0xff171d1e),
  surfaceContainer: Color(0xff1b2122),
  surfaceContainerHigh: Color(0xff252b2c),
  surfaceContainerHighest: Color(0xff303637),
);

void main() {
  runApp(const ReactiveThemeDemoApp());
}

/// A fully reactive demo wired on top of the reactive gateway/repo/watch flow.
class ReactiveThemeDemoApp extends StatefulWidget {
  const ReactiveThemeDemoApp({super.key});

  @override
  State<ReactiveThemeDemoApp> createState() => _ReactiveThemeDemoAppState();
}

class _ReactiveThemeDemoAppState extends State<ReactiveThemeDemoApp> {
  late final FakeServiceThemeReact _service;
  late final GatewayThemeReactImpl _gateway;
  late final RepositoryThemeReactImpl _repo;
  late final ThemeUsecases _usecases;
  late final WatchTheme _watch;
  late final BlocThemeReact _bloc;

  bool _autoToggle = false;
  Duration _period = const Duration(seconds: 10);

  @override
  void initState() {
    super.initState();

    // Preparamos overrides con tus ColorScheme para arrancar el bus JSON.
    const ThemeOverrides ov = ThemeOverrides(
      light: lightColorScheme,
      dark: darkColorScheme,
    );

    // JSON base para light/dark; el gateway normaliza y valida.
    final Map<String, dynamic> lightJson = <String, dynamic>{
      'mode': ThemeMode.light.name,
      'seed': seed.toARGB32(),
      'useM3': true,
      'textScale': 1.0,
      'preset': 'brand',
      'overrides': ov.toJson(),
    };
    final Map<String, dynamic> darkJson = <String, dynamic>{
      'mode': ThemeMode.dark.name,
      'seed': seed.toARGB32(),
      'useM3': true,
      'textScale': 1.0,
      'preset': 'brand',
      'overrides': ov.toJson(),
    };

    // 1) Service with your defaults (no auto-start; lo controlamos con el switch)
    _service = FakeServiceThemeReact(
      lightJson: lightJson,
      darkJson: darkJson,
      // Si deseas arrancar con TextThemeOverrides por defecto, añade: textOverridesJson: const TextThemeOverrides(...).toJson(),
      period: _period,
    );

    // 2) Gateway (normaliza + smoke-test de ThemeData)
    _gateway = GatewayThemeReactImpl(service: _service);

    // 3) Repository (mapea a ThemeState)
    _repo = RepositoryThemeReactImpl(gateway: _gateway);

    // 4) Usecases
    _usecases = ThemeUsecases.fromRepo(_repo);

    // 5) Watch use case
    _watch = WatchTheme(_repo);

    // 6) Reactive Bloc (se suscribe de inmediato)
    _bloc = BlocThemeReact(
      themeUsecases: _usecases,
      watchTheme: _watch,
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ThemeState>(
      stream: _bloc.stream,
      initialData: _bloc.stateOrDefault,
      builder: (BuildContext context, AsyncSnapshot<ThemeState> snap) {
        final ThemeState state = snap.data ?? ThemeState.defaults;
        final ThemeData theme = _bloc.themeData();

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: state.mode,
          theme: theme,
          darkTheme: theme, // BuildThemeData ya respeta brightness + overrides
          home: _HomePage(
            bloc: _bloc,
            service: _service,
            autoToggle: _autoToggle,
            period: _period,
            onToggleAuto: _handleAutoToggle,
            onChangePeriod: _handleChangePeriod,
          ),
        );
      },
    );
  }

  void _handleAutoToggle(bool value) {
    setState(() {
      _autoToggle = value;
      if (value) {
        _service.startAutoToggle(period: _period);
      } else {
        _service.stopAutoToggle();
      }
    });
  }

  void _handleChangePeriod(Duration next) {
    setState(() {
      _period = next;
      if (_autoToggle) {
        _service.startAutoToggle(period: _period); // reinicia con nuevo periodo
      }
    });
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage({
    required this.bloc,
    required this.service,
    required this.autoToggle,
    required this.period,
    required this.onToggleAuto,
    required this.onChangePeriod,
  });

  final BlocThemeReact bloc;
  final FakeServiceThemeReact service;
  final bool autoToggle;
  final Duration period;
  final ValueChanged<bool> onToggleAuto;
  final ValueChanged<Duration> onChangePeriod;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ThemeState>(
      stream: bloc.stream,
      initialData: bloc.stateOrDefault,
      builder: (BuildContext context, AsyncSnapshot<ThemeState> snap) {
        final ThemeState state = snap.data ?? ThemeState.defaults;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Reactive Theme Demo'),
            actions: <Widget>[
              IconButton(
                tooltip: 'Copy Theme JSON',
                icon: const Icon(Icons.copy_all),
                onPressed: () => _copyJson(context, state),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              _AutoToggleCard(
                autoToggle: autoToggle,
                period: period,
                onToggle: onToggleAuto,
                onChangePeriod: onChangePeriod,
                currentMode: state.mode,
              ),
              const SizedBox(height: 16),
              _GridActions(bloc: bloc),
              const SizedBox(height: 24),
              _StatePreview(state: state),
            ],
          ),
        );
      },
    );
  }

  Future<void> _copyJson(BuildContext context, ThemeState state) async {
    final Map<String, dynamic> json = state.toJson();
    await Clipboard.setData(ClipboardData(text: '$json'));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Theme JSON copied to clipboard')),
      );
    }
  }
}

class _AutoToggleCard extends StatelessWidget {
  const _AutoToggleCard({
    required this.autoToggle,
    required this.period,
    required this.onToggle,
    required this.onChangePeriod,
    required this.currentMode,
  });

  final bool autoToggle;
  final Duration period;
  final ValueChanged<bool> onToggle;
  final ValueChanged<Duration> onChangePeriod;
  final ThemeMode currentMode;

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Auto toggle (every ${period.inSeconds}s)',
                    style: tt.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text('Current: ${currentMode.name}', style: tt.bodyMedium),
                ],
              ),
            ),
            Switch(
              value: autoToggle,
              onChanged: onToggle,
            ),
            const SizedBox(width: 8),
            _PeriodMenu(
              current: period,
              onSelected: onChangePeriod,
            ),
          ],
        ),
      ),
    );
  }
}

class _PeriodMenu extends StatelessWidget {
  const _PeriodMenu({required this.current, required this.onSelected});
  final Duration current;
  final ValueChanged<Duration> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Duration>(
      tooltip: 'Change period',
      icon: const Icon(Icons.timer),
      onSelected: onSelected,
      itemBuilder: (BuildContext ctx) => const <PopupMenuEntry<Duration>>[
        PopupMenuItem<Duration>(
          value: Duration(seconds: 5),
          child: Text('5 s'),
        ),
        PopupMenuItem<Duration>(
          value: Duration(seconds: 10),
          child: Text('10 s'),
        ),
        PopupMenuItem<Duration>(
          value: Duration(seconds: 15),
          child: Text('15 s'),
        ),
        PopupMenuItem<Duration>(
          value: Duration(seconds: 30),
          child: Text('30 s'),
        ),
      ],
    );
  }
}

class _GridActions extends StatelessWidget {
  const _GridActions({required this.bloc});
  final BlocThemeReact bloc;

  @override
  Widget build(BuildContext context) {
    const double spacing = 12;
    return LayoutBuilder(
      builder: (BuildContext ctx, BoxConstraints c) {
        final double w = (c.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: <Widget>[
            _ActionCard(
              width: w,
              color: Colors.amber,
              label: 'Light',
              onTap: () => bloc.setMode(ThemeMode.light),
            ),
            _ActionCard(
              width: w,
              color: Colors.blueGrey,
              label: 'Dark',
              onTap: () => bloc.setMode(ThemeMode.dark),
            ),
            _ActionCard(
              width: w,
              color: Colors.teal,
              label: 'Randomize',
              onTap: () => bloc.randomTheme(),
            ),
            _ActionCard(
              width: w,
              color: Colors.indigo,
              label: 'TextOverrides',
              onTap: () => bloc.setTextThemeOverrides(
                const TextThemeOverrides(
                  light: TextTheme(
                    bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14),
                  ),
                  dark: TextTheme(
                    bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.width,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final double width;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = Theme.of(context).textTheme;
    return Material(
      color: color.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          width: width,
          height: 96,
          child: Center(
            child: Text(label, style: tt.titleMedium),
          ),
        ),
      ),
    );
  }
}

class _StatePreview extends StatelessWidget {
  const _StatePreview({required this.state});
  final ThemeState state;

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = Theme.of(context).textTheme;
    final Map<String, dynamic> json = state.toJson();
    return Card(
      margin: const EdgeInsets.only(bottom: 32),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: tt.bodySmall!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Snapshot', style: tt.titleMedium),
              const SizedBox(height: 8),
              Text('mode: ${state.mode.name}'),
              Text('useM3: ${state.useMaterial3}'),
              Text('textScale: ${state.textScale.toStringAsFixed(2)}'),
              Text('preset: ${state.preset}'),
              Text('seed: ${UtilsForTheme.colorToHex(state.seed)}'),
              const SizedBox(height: 8),
              Text('json: $json'),
            ],
          ),
        ),
      ),
    );
  }
}
