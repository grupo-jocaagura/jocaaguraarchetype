import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DsMainWidget());
}

/// ---------------------------------------------------------------------------
/// Helpers (tokens-first, con fallback seguro cuando aún no hay extension)
/// ---------------------------------------------------------------------------

double _tokOr(
  BuildContext context,
  double Function(ModelDsExtendedTokens t) pick,
  double fallback,
) {
  return DsExtendedTokensExtension.tokOr(context, pick, fallback);
}

EdgeInsets _padAll(BuildContext context, double fallback) {
  final double v =
      _tokOr(context, (ModelDsExtendedTokens t) => t.spacingSm, fallback);
  return EdgeInsets.all(v);
}

Widget gapXs(BuildContext context) => SizedBox(
      height: _tokOr(context, (ModelDsExtendedTokens t) => t.spacingXs, 4),
    );

Widget gapSm(BuildContext context) => SizedBox(
      height: _tokOr(context, (ModelDsExtendedTokens t) => t.spacingSm, 8),
    );

Widget gap(BuildContext context) => SizedBox(
      height: _tokOr(context, (ModelDsExtendedTokens t) => t.spacing, 16),
    );

Widget gapLg(BuildContext context) => SizedBox(
      height: _tokOr(context, (ModelDsExtendedTokens t) => t.spacingLg, 24),
    );

Widget gapXl(BuildContext context) => SizedBox(
      height: _tokOr(context, (ModelDsExtendedTokens t) => t.spacingXl, 32),
    );

/// ---------------------------------------------------------------------------
/// App
/// ---------------------------------------------------------------------------

class DsMainWidget extends StatefulWidget {
  const DsMainWidget({super.key});

  @override
  State<DsMainWidget> createState() => _DsMainWidgetState();
}

class _DsMainWidgetState extends State<DsMainWidget> {
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  late final BlocDesignSystem dsBloc;

  ThemeMode themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();

    final ModelDesignSystem initialDs = ModelDesignSystem(
      theme: ModelDesignSystem.fromThemeData(
        lightTheme: ThemeData.light(useMaterial3: true),
        darkTheme: ThemeData.dark(useMaterial3: true),
      ),
      tokens: const ModelDsExtendedTokens(),
      dataViz: ModelDataVizPalette.fallback(),
      semanticLight: ModelSemanticColors.fallbackLight(),
      semanticDark: ModelSemanticColors.fallbackDark(),
    );

    dsBloc = BlocDesignSystem(initialDs);
  }

  @override
  void dispose() {
    dsBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Either<ErrorItem, ModelDesignSystem>>(
      stream: dsBloc.dsStream,
      initialData: Right<ErrorItem, ModelDesignSystem>(dsBloc.lastGoodDs),
      builder: (_, AsyncSnapshot<Either<ErrorItem, ModelDesignSystem>> snap) {
        final Either<ErrorItem, ModelDesignSystem> either =
            snap.data ?? Right<ErrorItem, ModelDesignSystem>(dsBloc.lastGoodDs);

        // Para ThemeData usamos DS válido (si hay error, el último del bloc).

        final ModelDesignSystem dsForTheme =
            either.fold((_) => dsBloc.lastGoodDs, (ModelDesignSystem v) => v);
        return MaterialApp(
          title: 'Design System Example',
          scaffoldMessengerKey: _messengerKey,
          theme: dsForTheme.toThemeData(brightness: Brightness.light),
          darkTheme: dsForTheme.toThemeData(brightness: Brightness.dark),
          themeMode: themeMode,
          home: _Home(
            dsBloc: dsBloc,
            either: either,
            themeMode: themeMode,
            onThemeModeChanged: (ThemeMode mode) =>
                setState(() => themeMode = mode),
            onShowSnackBar: () {
              _messengerKey.currentState?.showSnackBar(
                const SnackBar(content: Text('SnackBar preview')),
              );
            },
          ),
        );
      },
    );
  }
}

class _Home extends StatelessWidget {
  const _Home({
    required this.dsBloc,
    required this.either,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.onShowSnackBar,
  });

  final BlocDesignSystem dsBloc;
  final Either<ErrorItem, ModelDesignSystem> either;

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final VoidCallback onShowSnackBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Example'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Show snackbar',
            icon: const Icon(Icons.notifications),
            onPressed: onShowSnackBar,
          ),
        ],
      ),
      body: Row(
        children: <Widget>[
          SideBarMenuWidget(
            dsBloc: dsBloc,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(
                _tokOr(
                  context,
                  (ModelDsExtendedTokens t) => t.spacingSm,
                  12,
                ),
              ),
              child: ListView(
                children: <Widget>[
                  _ThemeModeSegmented(
                    value: themeMode,
                    onChanged: onThemeModeChanged,
                  ),
                  gap(context),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: either.when(
                      (ErrorItem err) => _ErrorState(err: err),
                      (ModelDesignSystem ds) => _DsPreview(ds: ds),
                    ),
                  ),
                  gapLg(context),
                  DsTokenEditorWidget(dsBloc: dsBloc),
                  gapLg(context),
                  DsDataVizEditorWidget(dsBloc: dsBloc),
                  gapLg(context),
                  DsTextThemeEditorWidget(dsBloc: dsBloc),
                  gapLg(context),
                  DsImportExportWidget(dsBloc: dsBloc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SideBarMenuWidget extends StatelessWidget {
  const SideBarMenuWidget({
    required this.dsBloc,
    super.key,
  });

  final BlocDesignSystem dsBloc;
  @override
  Widget build(BuildContext context) {
    final double menuWidth =
        (MediaQuery.of(context).size.width * 0.25).clamp(100.0, 220.0);
    return SizedBox(
      width: menuWidth,
      height: MediaQuery.of(context).size.height,
      child: Padding(
        padding: _padAll(context, 12),
        child: ListView(
          children: <Widget>[
            Text(
              'Editor de colorScheme',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Theme'),
              onTap: () {},
            ),
            gapSm(context),
            ...colorEditorsBuilder(context, dsBloc),
            Text(
              'Editor de colores semanticos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ...semanticEditorsBuilder(context, dsBloc),
            gapSm(context),
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Tokens'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.insights),
              title: const Text('DataViz'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// ThemeMode Segmented
/// ---------------------------------------------------------------------------

class _ThemeModeSegmented extends StatelessWidget {
  const _ThemeModeSegmented({
    required this.value,
    required this.onChanged,
  });

  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tok = context.dsTokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Theme mode', style: Theme.of(context).textTheme.labelLarge),
        gapXs(context),
        SegmentedButton<ThemeMode>(
          selected: <ThemeMode>{value},
          onSelectionChanged: (Set<ThemeMode> selection) {
            if (selection.isNotEmpty) {
              onChanged(selection.first);
            }
          },
          segments: const <ButtonSegment<ThemeMode>>[
            ButtonSegment<ThemeMode>(
              value: ThemeMode.system,
              icon: Icon(Icons.brightness_auto),
              label: Text('System'),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.light,
              icon: Icon(Icons.light_mode),
              label: Text('Light'),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.dark,
              icon: Icon(Icons.dark_mode),
              label: Text('Dark'),
            ),
          ],
          style: ButtonStyle(
            padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
              EdgeInsets.symmetric(
                horizontal: tok.spacingSm,
                vertical: tok.spacingXs,
              ),
            ),
            shape: WidgetStatePropertyAll<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(tok.borderRadius),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------------
/// Preview de DS (Material nativo) — intacto (solo mínimos ajustes de estilo)
/// ---------------------------------------------------------------------------

class _DsPreview extends StatefulWidget {
  const _DsPreview({required this.ds});

  final ModelDesignSystem ds;

  @override
  State<_DsPreview> createState() => _DsPreviewState();
}

class _DsPreviewState extends State<_DsPreview> {
  final TextEditingController _controller =
      TextEditingController(text: 'Texto');
  bool _switchValue = true;
  double _sliderValue = 0.6;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final ColorScheme cs = t.colorScheme;

    final DsSemanticColorsExtension? semanticExt =
        t.extensions[DsSemanticColorsExtension] as DsSemanticColorsExtension?;
    final ModelSemanticColors? semantic = semanticExt?.semantic;

    final DsDataVizPaletteExtension? vizExt =
        t.extensions[DsDataVizPaletteExtension] as DsDataVizPaletteExtension?;
    final ModelDataVizPalette? viz = vizExt?.palette;

    final ModelDsExtendedTokens tok = context.dsTokens;

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.all(tok.spacingSm),
        children: <Widget>[
          const _SectionTitle(
            title: 'Typography & Surfaces',
            subtitle: 'TextTheme + Card/Dialog shapes + surface colors',
          ),
          Wrap(
            spacing: tok.spacing,
            runSpacing: tok.spacing,
            children: <Widget>[
              _InfoCard(
                title: 'Headline',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Display Large', style: t.textTheme.displayLarge),
                    gapSm(context),
                    Text('Title Medium', style: t.textTheme.titleMedium),
                    gapSm(context),
                    Text('Body Medium', style: t.textTheme.bodyMedium),
                  ],
                ),
              ),
              _InfoCard(
                title: 'Surface tokens',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _ColorRow(label: 'primary', color: cs.primary),
                    _ColorRow(label: 'surface', color: cs.surface),
                    _ColorRow(
                      label: 'surfaceContainerLow',
                      color: cs.surfaceContainerLow,
                    ),
                    _ColorRow(
                      label: 'outlineVariant',
                      color: cs.outlineVariant,
                    ),
                  ],
                ),
              ),
            ],
          ),
          gapLg(context),
          const _SectionTitle(
            title: 'Buttons',
            subtitle: 'Filled / Outlined / Text + disabled',
          ),
          Wrap(
            spacing: tok.spacingSm,
            runSpacing: tok.spacingSm,
            children: <Widget>[
              FilledButton(onPressed: () {}, child: const Text('Filled')),
              const FilledButton(
                onPressed: null,
                child: Text('Filled disabled'),
              ),
              OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
              const OutlinedButton(
                onPressed: null,
                child: Text('Outlined disabled'),
              ),
              TextButton(onPressed: () {}, child: const Text('Text')),
              const TextButton(onPressed: null, child: Text('Text disabled')),
              ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
            ],
          ),
          gapLg(context),
          const _SectionTitle(
            title: 'Inputs',
            subtitle: 'InputDecorationTheme (focused/error/disabled)',
          ),
          Wrap(
            spacing: tok.spacingSm,
            runSpacing: tok.spacingSm,
            children: <Widget>[
              SizedBox(
                width: 320,
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'TextField',
                    helperText: 'Helper',
                  ),
                ),
              ),
              const SizedBox(
                width: 320,
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'With error',
                    errorText: 'Error message',
                  ),
                ),
              ),
              const SizedBox(
                width: 320,
                child: TextField(
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Disabled',
                    hintText: 'Disabled hint',
                  ),
                ),
              ),
            ],
          ),
          gapLg(context),
          const _SectionTitle(
            title: 'ListTile, Switch, Slider, Progress',
            subtitle: 'Estados y controles comunes',
          ),
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('ListTile title'),
                  subtitle: const Text('Subtitle / secondary text'),
                  trailing: IconButton(
                    tooltip: 'Tooltip preview',
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {},
                  ),
                ),
                SwitchListTile(
                  value: _switchValue,
                  onChanged: (bool v) => setState(() => _switchValue = v),
                  title: const Text('SwitchListTile'),
                ),
                ListTile(
                  title: const Text('Slider'),
                  subtitle: Slider(
                    value: _sliderValue,
                    onChanged: (double v) => setState(() => _sliderValue = v),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(tok.spacing),
                  child: const LinearProgressIndicator(),
                ),
              ],
            ),
          ),
          gapLg(context),
          const _SectionTitle(
            title: 'Semantic Colors',
            subtitle: 'success / warning / info (chips + banner-like cards)',
          ),
          if (semantic == null)
            const Text('No semantic extension found in ThemeData.extensions.')
          else
            Wrap(
              spacing: tok.spacingSm,
              runSpacing: tok.spacingSm,
              children: <Widget>[
                _SemanticChip(
                  label: 'Success',
                  bg: semantic.successContainer,
                  fg: semantic.onSuccessContainer,
                  icon: Icons.check_circle,
                ),
                _SemanticChip(
                  label: 'Warning',
                  bg: semantic.warningContainer,
                  fg: semantic.onWarningContainer,
                  icon: Icons.warning_amber_rounded,
                ),
                _SemanticChip(
                  label: 'Info',
                  bg: semantic.infoContainer,
                  fg: semantic.onInfoContainer,
                  icon: Icons.info,
                ),
              ],
            ),
          gapSm(context),
          if (semantic != null)
            Wrap(
              spacing: tok.spacingSm,
              runSpacing: tok.spacingSm,
              children: <Widget>[
                _SemanticBanner(
                  title: 'Success banner',
                  message: 'Operación confirmada. Estado OK.',
                  bg: semantic.success,
                  fg: semantic.onSuccess,
                ),
                _SemanticBanner(
                  title: 'Warning banner',
                  message: 'Requiere revisión, pero no bloquea.',
                  bg: semantic.warning,
                  fg: semantic.onWarning,
                ),
                _SemanticBanner(
                  title: 'Info banner',
                  message: 'Contexto adicional para la pantalla.',
                  bg: semantic.info,
                  fg: semantic.onInfo,
                ),
              ],
            ),
          gapLg(context),
          const _SectionTitle(
            title: 'DataViz palette',
            subtitle: 'categorical (series) + sequential (0..1)',
          ),
          if (viz == null)
            const Text('No dataviz extension found in ThemeData.extensions.')
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Categorical series'),
                gapSm(context),
                Wrap(
                  spacing: tok.spacingXs,
                  runSpacing: tok.spacingXs,
                  children: List<Widget>.generate(
                    10,
                    (int i) => _Swatch(color: viz.categoricalAt(i)),
                  ),
                ),
                gap(context),
                const Text('Sequential scale'),
                gapSm(context),
                Row(
                  children: List<Widget>.generate(
                    8,
                    (int i) {
                      final double v = i / 7.0;
                      return Expanded(
                        child: Container(
                          height: tok.spacingLg,
                          color: viz.sequentialAt(v),
                        ),
                      );
                    },
                  ),
                ),
                gapSm(context),
                const Text('Mini chart'),
                gapSm(context),
                _MiniBarChart(viz: viz),
              ],
            ),
          gapLg(context),
          const _SectionTitle(
            title: 'Dialogs & BottomSheet',
            subtitle: 'Component themes en vivo',
          ),
          Wrap(
            spacing: tok.spacingSm,
            runSpacing: tok.spacingSm,
            children: <Widget>[
              FilledButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Dialog title'),
                    content:
                        const Text('Dialog content preview with DS shapes.'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
                child: const Text('Open Dialog'),
              ),
              OutlinedButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (_) => SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(tok.spacing),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('BottomSheet', style: t.textTheme.titleLarge),
                          gapSm(context),
                          const Text(
                            'Preview of BottomSheetTheme, padding and shapes.',
                          ),
                          gapSm(context),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Done'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                child: const Text('Open BottomSheet'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// UI Helpers (nativos)
/// ---------------------------------------------------------------------------

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.err});

  final ErrorItem err;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tok = context.dsTokens;
    return Center(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(tok.spacing),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.error_outline),
              gapSm(context),
              Text(err.title, style: Theme.of(context).textTheme.titleLarge),
              gapXs(context),
              Text(err.code),
              gapXs(context),
              Text(err.description),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: _tokOr(context, (ModelDsExtendedTokens t) => t.spacingSm, 12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: t.textTheme.titleLarge),
          SizedBox(
            height:
                _tokOr(context, (ModelDsExtendedTokens t) => t.spacingXs, 4),
          ),
          Text(subtitle, style: t.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(
            _tokOr(context, (ModelDsExtendedTokens t) => t.spacing, 16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              gapSm(context),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorRow extends StatelessWidget {
  const _ColorRow({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: _tokOr(context, (ModelDsExtendedTokens t) => t.spacingXs, 6),
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(width: 140, child: Text('')),
          Expanded(
            child: Row(
              children: <Widget>[
                SizedBox(width: 140, child: Text(label)),
                SizedBox(
                  width: _tokOr(
                    context,
                    (ModelDsExtendedTokens t) => t.spacingSm,
                    10,
                  ),
                ),
                _Swatch(color: color),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final double r =
        _tokOr(context, (ModelDsExtendedTokens t) => t.borderRadiusSm, 6);

    return Container(
      width: 28,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }
}

class _SemanticChip extends StatelessWidget {
  const _SemanticChip({
    required this.label,
    required this.bg,
    required this.fg,
    required this.icon,
  });

  final String label;
  final Color bg;
  final Color fg;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, color: fg),
      label: Text(label, style: TextStyle(color: fg)),
      backgroundColor: bg,
    );
  }
}

class _SemanticBanner extends StatelessWidget {
  const _SemanticBanner({
    required this.title,
    required this.message,
    required this.bg,
    required this.fg,
  });

  final String title;
  final String message;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Card(
        color: bg,
        child: Padding(
          padding: EdgeInsets.all(
            _tokOr(context, (ModelDsExtendedTokens t) => t.spacing, 16),
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: fg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: fg),
                ),
                SizedBox(
                  height: _tokOr(
                    context,
                    (ModelDsExtendedTokens t) => t.spacingXs,
                    6,
                  ),
                ),
                Text(message),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniBarChart extends StatelessWidget {
  const _MiniBarChart({required this.viz});

  final ModelDataVizPalette viz;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tok = context.dsTokens;
    final List<double> values = <double>[0.2, 0.55, 0.35, 0.8, 0.6];

    return Card(
      child: Padding(
        padding: EdgeInsets.all(tok.spacing),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List<Widget>.generate(values.length, (int i) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: tok.spacingXs),
                child: Container(
                  height: 120 * values[i],
                  decoration: BoxDecoration(
                    color: viz.categoricalAt(i),
                    borderRadius: BorderRadius.circular(tok.borderRadiusSm),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Editing color scheme Segmented
/// ---------------------------------------------------------------------------
List<ColorPaletteEditWidget> colorEditorsBuilder(
  BuildContext context,
  BlocDesignSystem dsBloc,
) {
  return <ColorPaletteEditWidget>[
    ColorPaletteEditWidget(
      label: 'primary',
      color: dsBloc
          .dsThemeFromBrightness(Theme.of(context).brightness)
          .colorScheme
          .primary,
      onChangeColorAttempt: (Color c) {
        final DsThemeTarget target =
            dsBloc.dsThemeTargetFromBrightness(Theme.of(context).brightness);
        dsBloc.patchThemeScheme(
          target: target,
          builder: (ColorScheme s) => s.copyWith(primary: c),
        );
      },
    ),
    ColorPaletteEditWidget(
      label: 'onPrimary',
      color: dsBloc
          .dsThemeFromBrightness(Theme.of(context).brightness)
          .colorScheme
          .onPrimary,
      onChangeColorAttempt: (Color c) {
        final DsThemeTarget target =
            dsBloc.dsThemeTargetFromBrightness(Theme.of(context).brightness);
        dsBloc.patchThemeScheme(
          target: target,
          builder: (ColorScheme s) => s.copyWith(onPrimary: c),
        );
      },
    ),
    ColorPaletteEditWidget(
      label: 'primaryContainer',
      color: dsBloc
          .dsThemeFromBrightness(Theme.of(context).brightness)
          .colorScheme
          .primaryContainer,
      onChangeColorAttempt: (Color c) {
        final DsThemeTarget target =
            dsBloc.dsThemeTargetFromBrightness(Theme.of(context).brightness);
        dsBloc.patchThemeScheme(
          target: target,
          builder: (ColorScheme s) => s.copyWith(primaryContainer: c),
        );
      },
    ),
    ColorPaletteEditWidget(
      label: 'onPrimaryContainer',
      color: dsBloc
          .dsThemeFromBrightness(Theme.of(context).brightness)
          .colorScheme
          .onPrimaryContainer,
      onChangeColorAttempt: (Color c) {
        final DsThemeTarget target =
            dsBloc.dsThemeTargetFromBrightness(Theme.of(context).brightness);
        dsBloc.patchThemeScheme(
          target: target,
          builder: (ColorScheme s) => s.copyWith(onPrimaryContainer: c),
        );
      },
    ),
    ColorPaletteEditWidget(
      label: 'inversePrimary',
      color: dsBloc
          .dsThemeFromBrightness(Theme.of(context).brightness)
          .colorScheme
          .inversePrimary,
      onChangeColorAttempt: (Color c) {
        final DsThemeTarget target =
            dsBloc.dsThemeTargetFromBrightness(Theme.of(context).brightness);
        dsBloc.patchThemeScheme(
          target: target,
          builder: (ColorScheme s) => s.copyWith(inversePrimary: c),
        );
      },
    ),
    ColorPaletteEditWidget(
      label: 'secondary',
      color: dsBloc
          .dsThemeFromBrightness(Theme.of(context).brightness)
          .colorScheme
          .secondary,
      onChangeColorAttempt: (Color c) {
        final DsThemeTarget target =
            dsBloc.dsThemeTargetFromBrightness(Theme.of(context).brightness);
        dsBloc.patchThemeScheme(
          target: target,
          builder: (ColorScheme s) => s.copyWith(secondary: c),
        );
      },
    ),
    ColorPaletteEditWidget(
      label: 'onSecondary',
      color: dsBloc
          .dsThemeFromBrightness(Theme.of(context).brightness)
          .colorScheme
          .onSecondary,
      onChangeColorAttempt: (Color c) {
        final DsThemeTarget target =
            dsBloc.dsThemeTargetFromBrightness(Theme.of(context).brightness);
        dsBloc.patchThemeScheme(
          target: target,
          builder: (ColorScheme s) => s.copyWith(onSecondary: c),
        );
      },
    ),
    ColorPaletteEditWidget(
      label: 'secondaryContainer',
      color: dsBloc
          .dsThemeFromBrightness(Theme.of(context).brightness)
          .colorScheme
          .secondaryContainer,
      onChangeColorAttempt: (Color c) {
        final DsThemeTarget target =
            dsBloc.dsThemeTargetFromBrightness(Theme.of(context).brightness);
        dsBloc.patchThemeScheme(
          target: target,
          builder: (ColorScheme s) => s.copyWith(secondaryContainer: c),
        );
      },
    ),
    ColorPaletteEditWidget(
      label: 'onSecondaryContainer',
      color: dsBloc
          .dsThemeFromBrightness(Theme.of(context).brightness)
          .colorScheme
          .onSecondaryContainer,
      onChangeColorAttempt: (Color c) {
        final DsThemeTarget target =
            dsBloc.dsThemeTargetFromBrightness(Theme.of(context).brightness);
        dsBloc.patchThemeScheme(
          target: target,
          builder: (ColorScheme s) => s.copyWith(onSecondaryContainer: c),
        );
      },
    ),
    ColorPaletteEditWidget(
      label: 'tertiary',
      color: dsBloc
          .dsThemeFromBrightness(Theme.of(context).brightness)
          .colorScheme
          .tertiary,
      onChangeColorAttempt: (Color c) {
        final DsThemeTarget target =
            dsBloc.dsThemeTargetFromBrightness(Theme.of(context).brightness);
        dsBloc.patchThemeScheme(
          target: target,
          builder: (ColorScheme s) => s.copyWith(tertiary: c),
        );
      },
    ),
    ColorPaletteEditWidget(
      label: 'onTertiary',
      color: dsBloc
          .dsThemeFromBrightness(Theme.of(context).brightness)
          .colorScheme
          .onTertiary,
      onChangeColorAttempt: (Color c) {
        final DsThemeTarget target =
            dsBloc.dsThemeTargetFromBrightness(Theme.of(context).brightness);
        dsBloc.patchThemeScheme(
          target: target,
          builder: (ColorScheme s) => s.copyWith(onTertiary: c),
        );
      },
    ),
    ColorPaletteEditWidget(
      label: 'tertiaryContainer',
      color: dsBloc
          .dsThemeFromBrightness(Theme.of(context).brightness)
          .colorScheme
          .tertiaryContainer,
      onChangeColorAttempt: (Color c) {
        final DsThemeTarget target =
            dsBloc.dsThemeTargetFromBrightness(Theme.of(context).brightness);
        dsBloc.patchThemeScheme(
          target: target,
          builder: (ColorScheme s) => s.copyWith(tertiaryContainer: c),
        );
      },
    ),
    ColorPaletteEditWidget(
      label: 'onTertiaryContainer',
      color: dsBloc
          .dsThemeFromBrightness(Theme.of(context).brightness)
          .colorScheme
          .onTertiaryContainer,
      onChangeColorAttempt: (Color c) {
        final DsThemeTarget target =
            dsBloc.dsThemeTargetFromBrightness(Theme.of(context).brightness);
        dsBloc.patchThemeScheme(
          target: target,
          builder: (ColorScheme s) => s.copyWith(onTertiaryContainer: c),
        );
      },
    ),
    ColorPaletteEditWidget(
      label: 'error',
      color: dsBloc
          .dsThemeFromBrightness(Theme.of(context).brightness)
          .colorScheme
          .error,
      onChangeColorAttempt: (Color c) {
        final DsThemeTarget target =
            dsBloc.dsThemeTargetFromBrightness(Theme.of(context).brightness);
        dsBloc.patchThemeScheme(
          target: target,
          builder: (ColorScheme s) => s.copyWith(error: c),
        );
      },
    ),
    ColorPaletteEditWidget(
      label: 'onError',
      color: dsBloc
          .dsThemeFromBrightness(Theme.of(context).brightness)
          .colorScheme
          .onError,
      onChangeColorAttempt: (Color c) {
        final DsThemeTarget target =
            dsBloc.dsThemeTargetFromBrightness(Theme.of(context).brightness);
        dsBloc.patchThemeScheme(
          target: target,
          builder: (ColorScheme s) => s.copyWith(onError: c),
        );
      },
    ),
    ColorPaletteEditWidget(
      label: 'errorContainer',
      color: dsBloc
          .dsThemeFromBrightness(Theme.of(context).brightness)
          .colorScheme
          .errorContainer,
      onChangeColorAttempt: (Color c) {
        final DsThemeTarget target =
            dsBloc.dsThemeTargetFromBrightness(Theme.of(context).brightness);
        dsBloc.patchThemeScheme(
          target: target,
          builder: (ColorScheme s) => s.copyWith(errorContainer: c),
        );
      },
    ),
    ColorPaletteEditWidget(
      label: 'onErrorContainer',
      color: dsBloc
          .dsThemeFromBrightness(Theme.of(context).brightness)
          .colorScheme
          .onErrorContainer,
      onChangeColorAttempt: (Color c) {
        final DsThemeTarget target =
            dsBloc.dsThemeTargetFromBrightness(Theme.of(context).brightness);
        dsBloc.patchThemeScheme(
          target: target,
          builder: (ColorScheme s) => s.copyWith(onErrorContainer: c),
        );
      },
    ),
    ColorPaletteEditWidget(
      label: 'surface',
      color: dsBloc
          .dsThemeFromBrightness(Theme.of(context).brightness)
          .colorScheme
          .surface,
      onChangeColorAttempt: (Color c) {
        final DsThemeTarget target =
            dsBloc.dsThemeTargetFromBrightness(Theme.of(context).brightness);
        dsBloc.patchThemeScheme(
          target: target,
          builder: (ColorScheme s) => s.copyWith(surface: c),
        );
      },
    ),
    ColorPaletteEditWidget(
      label: 'onSurface',
      color: dsBloc
          .dsThemeFromBrightness(Theme.of(context).brightness)
          .colorScheme
          .onSurface,
      onChangeColorAttempt: (Color c) {
        final DsThemeTarget target =
            dsBloc.dsThemeTargetFromBrightness(Theme.of(context).brightness);
        dsBloc.patchThemeScheme(
          target: target,
          builder: (ColorScheme s) => s.copyWith(onSurface: c),
        );
      },
    ),
    ColorPaletteEditWidget(
      label: 'surfaceTint',
      color: dsBloc
          .dsThemeFromBrightness(Theme.of(context).brightness)
          .colorScheme
          .surfaceTint,
      onChangeColorAttempt: (Color c) {
        final DsThemeTarget target =
            dsBloc.dsThemeTargetFromBrightness(Theme.of(context).brightness);
        dsBloc.patchThemeScheme(
          target: target,
          builder: (ColorScheme s) => s.copyWith(surfaceTint: c),
        );
      },
    ),
    ColorPaletteEditWidget(
      label: 'inverseSurface',
      color: dsBloc
          .dsThemeFromBrightness(Theme.of(context).brightness)
          .colorScheme
          .inverseSurface,
      onChangeColorAttempt: (Color c) {
        final DsThemeTarget target =
            dsBloc.dsThemeTargetFromBrightness(Theme.of(context).brightness);
        dsBloc.patchThemeScheme(
          target: target,
          builder: (ColorScheme s) => s.copyWith(inverseSurface: c),
        );
      },
    ),
    ColorPaletteEditWidget(
      label: 'onInverseSurface',
      color: dsBloc
          .dsThemeFromBrightness(Theme.of(context).brightness)
          .colorScheme
          .onInverseSurface,
      onChangeColorAttempt: (Color c) {
        final DsThemeTarget target =
            dsBloc.dsThemeTargetFromBrightness(Theme.of(context).brightness);
        dsBloc.patchThemeScheme(
          target: target,
          builder: (ColorScheme s) => s.copyWith(onInverseSurface: c),
        );
      },
    ),
    ColorPaletteEditWidget(
      label: 'outline',
      color: dsBloc
          .dsThemeFromBrightness(Theme.of(context).brightness)
          .colorScheme
          .outline,
      onChangeColorAttempt: (Color c) {
        final DsThemeTarget target =
            dsBloc.dsThemeTargetFromBrightness(Theme.of(context).brightness);
        dsBloc.patchThemeScheme(
          target: target,
          builder: (ColorScheme s) => s.copyWith(outline: c),
        );
      },
    ),
    ColorPaletteEditWidget(
      label: 'outlineVariant',
      color: dsBloc
          .dsThemeFromBrightness(Theme.of(context).brightness)
          .colorScheme
          .outlineVariant,
      onChangeColorAttempt: (Color c) {
        final DsThemeTarget target =
            dsBloc.dsThemeTargetFromBrightness(Theme.of(context).brightness);
        dsBloc.patchThemeScheme(
          target: target,
          builder: (ColorScheme s) => s.copyWith(outlineVariant: c),
        );
      },
    ),
    ColorPaletteEditWidget(
      label: 'shadow',
      color: dsBloc
          .dsThemeFromBrightness(Theme.of(context).brightness)
          .colorScheme
          .shadow,
      onChangeColorAttempt: (Color c) {
        final DsThemeTarget target =
            dsBloc.dsThemeTargetFromBrightness(Theme.of(context).brightness);
        dsBloc.patchThemeScheme(
          target: target,
          builder: (ColorScheme s) => s.copyWith(shadow: c),
        );
      },
    ),
    ColorPaletteEditWidget(
      label: 'scrim',
      color: dsBloc
          .dsThemeFromBrightness(Theme.of(context).brightness)
          .colorScheme
          .scrim,
      onChangeColorAttempt: (Color c) {
        final DsThemeTarget target =
            dsBloc.dsThemeTargetFromBrightness(Theme.of(context).brightness);
        dsBloc.patchThemeScheme(
          target: target,
          builder: (ColorScheme s) => s.copyWith(scrim: c),
        );
      },
    ),
  ];
}

// ---------------------------------------------------------------------------
// Semantic (Light/Dark) — SideBarMenuWidget children
// ---------------------------------------------------------------------------
List<ColorPaletteEditWidget> semanticEditorsBuilder(
  BuildContext context,
  BlocDesignSystem dsBloc,
) {
  return <ColorPaletteEditWidget>[
    ColorPaletteEditWidget(
      label: 'semantic.success',
      color: dsBloc.semanticFor(Theme.of(context).brightness).success,
      onChangeColorAttempt: (Color c) {
        dsBloc.patchSemanticPairFor(
          brightness: Theme.of(context).brightness,
          pairKey: ModelSemanticColorsKeys.success,
          background: c,
        );
      },
    ),
    ColorPaletteEditWidget(
      label: 'semantic.successContainer',
      color: dsBloc.semanticFor(Theme.of(context).brightness).successContainer,
      onChangeColorAttempt: (Color c) {
        dsBloc.patchSemanticPairFor(
          brightness: Theme.of(context).brightness,
          pairKey: ModelSemanticColorsKeys.successContainer,
          background: c,
        );
      },
    ),
    ColorPaletteEditWidget(
      label: 'semantic.warning',
      color: dsBloc.semanticFor(Theme.of(context).brightness).warning,
      onChangeColorAttempt: (Color c) {
        dsBloc.patchSemanticPairFor(
          brightness: Theme.of(context).brightness,
          pairKey: ModelSemanticColorsKeys.warning,
          background: c,
        );
      },
    ),
    ColorPaletteEditWidget(
      label: 'semantic.warningContainer',
      color: dsBloc.semanticFor(Theme.of(context).brightness).warningContainer,
      onChangeColorAttempt: (Color c) {
        dsBloc.patchSemanticPairFor(
          brightness: Theme.of(context).brightness,
          pairKey: ModelSemanticColorsKeys.warningContainer,
          background: c,
        );
      },
    ),
    ColorPaletteEditWidget(
      label: 'semantic.info',
      color: dsBloc.semanticFor(Theme.of(context).brightness).info,
      onChangeColorAttempt: (Color c) {
        dsBloc.patchSemanticPairFor(
          brightness: Theme.of(context).brightness,
          pairKey: ModelSemanticColorsKeys.info,
          background: c,
        );
      },
    ),
    ColorPaletteEditWidget(
      label: 'semantic.infoContainer',
      color: dsBloc.semanticFor(Theme.of(context).brightness).infoContainer,
      onChangeColorAttempt: (Color c) {
        dsBloc.patchSemanticPairFor(
          brightness: Theme.of(context).brightness,
          pairKey: ModelSemanticColorsKeys.infoContainer,
          background: c,
        );
      },
    ),
  ];
}
