import 'package:flutter/material.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  runApp(const DsMainWidget());
}

final ModelDesignSystem ds = ModelDesignSystem(
  theme: ModelDesignSystem.fromThemeData(
    lightTheme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
  ),
  tokens: const ModelDsExtendedTokens(),
  dataViz: ModelDataVizPalette.fallback(),
  semanticLight: ModelSemanticColors.fallbackLight(),
  semanticDark: ModelSemanticColors.fallbackDark(),
);

final BlocDesignSystem dsBloc = BlocDesignSystem(ds);
double _dsGap(BuildContext context, double fallback) {
  final DsExtendedTokensExtension? ext =
      Theme.of(context).extension<DsExtendedTokensExtension>();
  return ext?.tokens.spacingSm ?? fallback;
}

Widget gapXs(BuildContext context) => SizedBox(height: _dsGap(context, 4));

Widget gapSm(BuildContext context) => SizedBox(height: _dsGap(context, 8));

Widget gap(BuildContext context) => SizedBox(height: _dsGap(context, 16));

Widget gapLg(BuildContext context) => SizedBox(
      height: Theme.of(context)
              .extension<DsExtendedTokensExtension>()
              ?.tokens
              .spacingLg ??
          24,
    );

Widget gapXl(BuildContext context) => SizedBox(
      height: Theme.of(context)
              .extension<DsExtendedTokensExtension>()
              ?.tokens
              .spacingXl ??
          32,
    );

class DsMainWidget extends StatefulWidget {
  const DsMainWidget({super.key});

  @override
  State<DsMainWidget> createState() => _DsMainWidgetState();
}

class _DsMainWidgetState extends State<DsMainWidget> {
  ThemeMode themeMode = ThemeMode.system;
  @override
  Widget build(BuildContext context) {
    final double menuWidth =
        (MediaQuery.of(context).size.width * 0.25).clamp(50.0, 200.0);

    return MaterialApp(
      title: 'Design System Example',
      theme: dsBloc.buildThemeDataLightOrNull(),
      darkTheme: dsBloc.buildThemeDataDarkOrNull(),
      themeMode: themeMode,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Design System Example'),
          actions: <Widget>[
            IconButton(
              tooltip: 'Show snackbar',
              icon: const Icon(Icons.notifications),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('SnackBar preview')),
                );
              },
            ),
          ],
        ),
        body: StreamBuilder<Either<ErrorItem, ModelDesignSystem>>(
          stream: dsBloc.dsStream,
          builder:
              (_, AsyncSnapshot<Either<ErrorItem, ModelDesignSystem>> snap) {
            final Either<ErrorItem, ModelDesignSystem> either = snap.data ??
                Right<ErrorItem, ModelDesignSystem>(dsBloc.requireDs());

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: menuWidth,
                  height: MediaQuery.of(context).size.height,
                  padding: const EdgeInsets.all(12),
                  child: ListView(
                    children: <Widget>[
                      const Text('Menú'),
                      gapSm(context),
                      ListTile(
                        leading: const Icon(Icons.palette),
                        title: const Text('Theme'),
                        onTap: () {},
                      ),
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
                Expanded(
                  child: Column(
                    children: <Widget>[
                      _ThemeModeSegmented(
                        value: themeMode,
                        onChanged: (ThemeMode mode) =>
                            setState(() => themeMode = mode),
                      ),
                      gapSm(context),
                      Expanded(
                        child: either.when(
                          (ErrorItem err) => _ErrorState(err: err),
                          (ModelDesignSystem ds) => _DsPreview(ds: ds),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

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
            if (selection.isEmpty) {
              return;
            }
            onChanged(selection.first);
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

/// ------------------------------
/// Preview de DS (Material nativo)
/// ------------------------------
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
        padding: EdgeInsets.all(context.dsTokens.spacingSm),
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
              FilledButton(
                onPressed: () {},
                child: const Text('Filled'),
              ),
              const FilledButton(
                onPressed: null,
                child: Text('Filled disabled'),
              ),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Outlined'),
              ),
              const OutlinedButton(
                onPressed: null,
                child: Text('Outlined disabled'),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Text'),
              ),
              const TextButton(
                onPressed: null,
                child: Text('Text disabled'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Elevated'),
              ),
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
                      final double t = i / 7.0;
                      return Expanded(
                        child: Container(
                          height: tok.spacingLg,
                          color: viz.sequentialAt(t),
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

/// ------------------------------
/// UI Helpers (nativos)
/// ------------------------------
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: t.textTheme.titleLarge),
          const SizedBox(height: 4),
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
          padding: const EdgeInsets.all(16),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          SizedBox(width: 140, child: Text(label)),
          const SizedBox(width: 10),
          _Swatch(color: color),
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
    return Container(
      width: 28,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
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
          padding: const EdgeInsets.all(16),
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
                const SizedBox(height: 6),
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
    final List<double> values = <double>[0.2, 0.55, 0.35, 0.8, 0.6];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List<Widget>.generate(values.length, (int i) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Container(
                  height: 120 * values[i],
                  decoration: BoxDecoration(
                    color: viz.categoricalAt(i),
                    borderRadius: BorderRadius.circular(8),
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
