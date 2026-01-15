// main.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

void main() {
  runApp(const ThemeBuilderDemoApp());
}

class ThemeBuilderDemoApp extends StatefulWidget {
  const ThemeBuilderDemoApp({super.key});

  @override
  State<ThemeBuilderDemoApp> createState() => _ThemeBuilderDemoAppState();
}

class _ThemeBuilderDemoAppState extends State<ThemeBuilderDemoApp> {
  late ModelThemeData _themeModel;
  ThemeMode _mode = ThemeMode.system;

  // UI state
  bool _useMaterial3 = true;
  double _fontScale = 1.0;
  Color _seed = Colors.indigo;

  @override
  void initState() {
    super.initState();
    _themeModel = _buildModelThemeData(
      seed: _seed,
      useMaterial3: _useMaterial3,
      fontScale: _fontScale,
    );
  }

  void _rebuildThemeModel() {
    setState(() {
      _themeModel = _buildModelThemeData(
        seed: _seed,
        useMaterial3: _useMaterial3,
        fontScale: _fontScale,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData light =
        _themeModel.toThemeData(brightness: Brightness.light);
    final ThemeData dark = _themeModel.toThemeData(brightness: Brightness.dark);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jocaagura ThemeBuilder Demo',
      themeMode: _mode,
      theme: light,
      darkTheme: dark,
      home: ThemeBuilderHome(
        mode: _mode,
        onModeChanged: (ThemeMode v) => setState(() => _mode = v),
        seed: _seed,
        onSeedChanged: (Color v) {
          _seed = v;
          _rebuildThemeModel();
        },
        useMaterial3: _useMaterial3,
        onUseMaterial3Changed: (bool v) {
          _useMaterial3 = v;
          _rebuildThemeModel();
        },
        fontScale: _fontScale,
        onFontScaleChanged: (double v) {
          _fontScale = v;
          _rebuildThemeModel();
        },
        themeModel: _themeModel,
        onThemeModelImported: (ModelThemeData v) {
          setState(() {
            _themeModel = v;
            _useMaterial3 = v.useMaterial3;

            // Intento "suave" de inferir seed (no es reversible 100%):
            _seed = v.lightScheme.primary;
            _fontScale = 1.0;
          });
        },
        onReset: () {
          setState(() {
            _seed = Colors.indigo;
            _useMaterial3 = true;
            _fontScale = 1.0;
            _mode = ThemeMode.system;
            _themeModel = _buildModelThemeData(
              seed: _seed,
              useMaterial3: _useMaterial3,
              fontScale: _fontScale,
            );
          });
        },
      ),
    );
  }
}

class ThemeBuilderHome extends StatelessWidget {
  const ThemeBuilderHome({
    required this.mode,
    required this.onModeChanged,
    required this.seed,
    required this.onSeedChanged,
    required this.useMaterial3,
    required this.onUseMaterial3Changed,
    required this.fontScale,
    required this.onFontScaleChanged,
    required this.themeModel,
    required this.onThemeModelImported,
    required this.onReset,
    super.key,
  });

  final ThemeMode mode;
  final ValueChanged<ThemeMode> onModeChanged;

  final Color seed;
  final ValueChanged<Color> onSeedChanged;

  final bool useMaterial3;
  final ValueChanged<bool> onUseMaterial3Changed;

  final double fontScale;
  final ValueChanged<double> onFontScaleChanged;

  final ModelThemeData themeModel;
  final ValueChanged<ModelThemeData> onThemeModelImported;

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ThemeBuilder (ModelThemeData)'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Copy JSON',
            onPressed: () => _copyJson(context, themeModel),
            icon: const Icon(Icons.content_copy),
          ),
          IconButton(
            tooltip: 'Import JSON',
            onPressed: () => _importJsonDialog(context, onThemeModelImported),
            icon: const Icon(Icons.upload_file),
          ),
          IconButton(
            tooltip: 'Reset',
            onPressed: onReset,
            icon: const Icon(Icons.restart_alt),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          final bool isWide = c.maxWidth >= 900;
          final Widget controls = _ControlsPanel(
            mode: mode,
            onModeChanged: onModeChanged,
            seed: seed,
            onSeedChanged: onSeedChanged,
            useMaterial3: useMaterial3,
            onUseMaterial3Changed: onUseMaterial3Changed,
            fontScale: fontScale,
            onFontScaleChanged: onFontScaleChanged,
            themeModel: themeModel,
          );

          final Widget preview = _PreviewPanel(
            primaryHex: UtilsForTheme.colorToHex(scheme.primary),
            surfaceHex: UtilsForTheme.colorToHex(scheme.surface),
          );

          if (isWide) {
            return Row(
              children: <Widget>[
                SizedBox(width: 420, child: controls),
                const VerticalDivider(width: 1),
                Expanded(child: preview),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: <Widget>[
              controls,
              const Divider(height: 1),
              SizedBox(height: 520, child: preview),
            ],
          );
        },
      ),
    );
  }

  static Future<void> _copyJson(
    BuildContext context,
    ModelThemeData model,
  ) async {
    final Map<String, dynamic> json = model.toJson();
    final String pretty = const JsonEncoder.withIndent('  ').convert(json);

    await Clipboard.setData(ClipboardData(text: pretty));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Theme JSON copied to clipboard')),
      );
    }
  }

  static Future<void> _importJsonDialog(
    BuildContext context,
    ValueChanged<ModelThemeData> onImported,
  ) async {
    final TextEditingController c = TextEditingController();
    final ModelThemeData? imported = await showDialog<ModelThemeData>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Import Theme JSON'),
        content: SizedBox(
          width: 700,
          child: TextField(
            controller: c,
            minLines: 10,
            maxLines: 18,
            decoration: const InputDecoration(
              hintText: '{\n  "useMaterial3": true,\n  ...\n}',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () {
              try {
                final Object? decoded = jsonDecode(c.text.trim());
                if (decoded is! Map<String, dynamic>) {
                  throw const FormatException('JSON root must be an object');
                }
                final ModelThemeData m = ModelThemeData.fromJson(decoded);
                Navigator.of(ctx).pop(m);
              } catch (e) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text('Invalid JSON: $e')),
                );
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('Apply'),
          ),
        ],
      ),
    );

    if (imported != null) {
      onImported(imported);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Theme imported successfully')),
        );
      }
    }
  }
}

class _ControlsPanel extends StatelessWidget {
  const _ControlsPanel({
    required this.mode,
    required this.onModeChanged,
    required this.seed,
    required this.onSeedChanged,
    required this.useMaterial3,
    required this.onUseMaterial3Changed,
    required this.fontScale,
    required this.onFontScaleChanged,
    required this.themeModel,
  });

  final ThemeMode mode;
  final ValueChanged<ThemeMode> onModeChanged;

  final Color seed;
  final ValueChanged<Color> onSeedChanged;

  final bool useMaterial3;
  final ValueChanged<bool> onUseMaterial3Changed;

  final double fontScale;
  final ValueChanged<double> onFontScaleChanged;

  final ModelThemeData themeModel;

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text('Controls', style: tt.titleLarge),
                    const SizedBox(height: 12),
                    _ThemeModePicker(value: mode, onChanged: onModeChanged),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: useMaterial3,
                      onChanged: onUseMaterial3Changed,
                      title: const Text('useMaterial3'),
                      subtitle:
                          Text('Current: ${useMaterial3 ? 'true' : 'false'}'),
                    ),
                    const SizedBox(height: 12),
                    _SeedPicker(value: seed, onChanged: onSeedChanged),
                    const SizedBox(height: 12),
                    Text('Font scale: ${fontScale.toStringAsFixed(2)}'),
                    Slider(
                      value: fontScale,
                      min: 0.85,
                      max: 1.25,
                      divisions: 40,
                      label: fontScale.toStringAsFixed(2),
                      onChanged: onFontScaleChanged,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _ThemeSnapshot(themeModel: themeModel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeModePicker extends StatelessWidget {
  const _ThemeModePicker({required this.value, required this.onChanged});

  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ThemeMode>(
      segments: const <ButtonSegment<ThemeMode>>[
        ButtonSegment<ThemeMode>(
          value: ThemeMode.system,
          label: Text('System'),
        ),
        ButtonSegment<ThemeMode>(value: ThemeMode.light, label: Text('Light')),
        ButtonSegment<ThemeMode>(value: ThemeMode.dark, label: Text('Dark')),
      ],
      selected: <ThemeMode>{value},
      onSelectionChanged: (Set<ThemeMode> s) => onChanged(s.first),
    );
  }
}

class _SeedPicker extends StatelessWidget {
  const _SeedPicker({required this.value, required this.onChanged});

  final Color value;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    final List<_SeedOption> options = <_SeedOption>[
      const _SeedOption(name: 'Indigo', color: Colors.indigo),
      const _SeedOption(name: 'Teal', color: Colors.teal),
      const _SeedOption(name: 'Orange', color: Colors.deepOrange),
      const _SeedOption(name: 'Pink', color: Colors.pink),
      const _SeedOption(name: 'BlueGrey', color: Colors.blueGrey),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('Seed color'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((_SeedOption o) {
            final bool selected = value.toARGB32() == o.color.toARGB32();
            return ChoiceChip(
              selected: selected,
              label: Text(o.name),
              avatar: CircleAvatar(backgroundColor: o.color),
              onSelected: (_) => onChanged(o.color),
            );
          }).toList(growable: false),
        ),
      ],
    );
  }
}

class _SeedOption {
  const _SeedOption({required this.name, required this.color});

  final String name;
  final Color color;
}

class _ThemeSnapshot extends StatelessWidget {
  const _ThemeSnapshot({required this.themeModel});

  final ModelThemeData themeModel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme light = themeModel.lightScheme;
    final ColorScheme dark = themeModel.darkScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Text('Snapshot'),
        const SizedBox(height: 8),
        _kv('useMaterial3', '${themeModel.useMaterial3}'),
        _kv('light.primary', UtilsForTheme.colorToHex(light.primary)),
        _kv('light.surface', UtilsForTheme.colorToHex(light.surface)),
        _kv('dark.primary', UtilsForTheme.colorToHex(dark.primary)),
        _kv('dark.surface', UtilsForTheme.colorToHex(dark.surface)),
        const SizedBox(height: 8),
        const Text(
          'Tip: usa el botón “Copy JSON” para pegar en un Issue/PR o para guardarlo en Drive/Sheets.',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  static Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 140,
            child: Text(k, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: SelectableText(
              v,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewPanel extends StatefulWidget {
  const _PreviewPanel({
    required this.primaryHex,
    required this.surfaceHex,
  });

  final String primaryHex;
  final String surfaceHex;

  @override
  State<_PreviewPanel> createState() => _PreviewPanelState();
}

class _PreviewPanelState extends State<_PreviewPanel> {
  bool _switchValue = true;
  final TextEditingController _text =
      TextEditingController(text: 'Hello Jocaagura 👋');

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: scheme.surfaceContainer,
              child: Row(
                children: <Widget>[
                  Text('Preview', style: tt.titleMedium),
                  const Spacer(),
                  Text(
                    'primary=${widget.primaryHex} • surface=${widget.surfaceHex}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  Text('Headline Small', style: tt.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    'Esto es un preview rápido para ver cómo se comportan '
                    'TextTheme + ColorScheme en componentes típicos.',
                    style: tt.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _text,
                    decoration: const InputDecoration(
                      labelText: 'TextField',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('FilledButton tapped'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.auto_fix_high),
                          label: const Text('Action'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.tune),
                          label: const Text('Secondary'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('SwitchListTile'),
                    value: _switchValue,
                    onChanged: (bool v) => setState(() => _switchValue = v),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.palette),
                      title: const Text('Card + ListTile'),
                      subtitle: Text(
                        'primary: ${UtilsForTheme.colorToHex(scheme.primary)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Builds a JSON-roundtrippable ModelThemeData using Material defaults.
ModelThemeData _buildModelThemeData({
  required Color seed,
  required bool useMaterial3,
  required double fontScale,
}) {
  final ThemeData lightBase = ThemeData(
    useMaterial3: useMaterial3,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
    ),
  );

  final ThemeData darkBase = ThemeData(
    useMaterial3: useMaterial3,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    ),
  );

  final TextTheme lightText = _scaledTextTheme(
    base: Typography.material2021(platform: TargetPlatform.windows).black,
    scale: fontScale,
    fallbackFrom: lightBase.textTheme,
  );

  final TextTheme darkText = _scaledTextTheme(
    base: Typography.material2021(platform: TargetPlatform.windows).white,
    scale: fontScale,
    fallbackFrom: darkBase.textTheme,
  );

  return ModelThemeData(
    useMaterial3: useMaterial3,
    lightScheme: lightBase.colorScheme,
    darkScheme: darkBase.colorScheme,
    lightTextTheme: lightText,
    darkTextTheme: darkText,
  );
}

TextTheme _scaledTextTheme({
  required TextTheme base,
  required double scale,
  required TextTheme fallbackFrom,
}) {
  // Si scale es 1.0 devolvemos algo estable sin tocar tamaños.
  if (scale == 1.0) {
    return fallbackFrom;
  }

  TextStyle? s(TextStyle? style, TextStyle? fallback) {
    if (style == null && fallback == null) {
      return null;
    }
    final TextStyle resolved = (style ?? fallback!).merge(fallback);

    // 👇 Garantiza fontSize != null antes de escalar
    final double baseSize = resolved.fontSize ?? 14.0;

    // ⚠️ Evitamos .apply(fontSizeFactor:) para no disparar asserts.
    return resolved.copyWith(fontSize: baseSize * scale);
  }

  return TextTheme(
    displayLarge: s(base.displayLarge, fallbackFrom.displayLarge),
    displayMedium: s(base.displayMedium, fallbackFrom.displayMedium),
    displaySmall: s(base.displaySmall, fallbackFrom.displaySmall),
    headlineLarge: s(base.headlineLarge, fallbackFrom.headlineLarge),
    headlineMedium: s(base.headlineMedium, fallbackFrom.headlineMedium),
    headlineSmall: s(base.headlineSmall, fallbackFrom.headlineSmall),
    titleLarge: s(base.titleLarge, fallbackFrom.titleLarge),
    titleMedium: s(base.titleMedium, fallbackFrom.titleMedium),
    titleSmall: s(base.titleSmall, fallbackFrom.titleSmall),
    bodyLarge: s(base.bodyLarge, fallbackFrom.bodyLarge),
    bodyMedium: s(base.bodyMedium, fallbackFrom.bodyMedium),
    bodySmall: s(base.bodySmall, fallbackFrom.bodySmall),
    labelLarge: s(base.labelLarge, fallbackFrom.labelLarge),
    labelMedium: s(base.labelMedium, fallbackFrom.labelMedium),
    labelSmall: s(base.labelSmall, fallbackFrom.labelSmall),
  );
}
