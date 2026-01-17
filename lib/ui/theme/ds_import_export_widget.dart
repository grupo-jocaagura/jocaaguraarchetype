part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Widget transversal para Export/Import del DesignSystem vía Portapapeles.
/// - Export: dsBloc.exportToJson() -> JSON pretty -> Clipboard
/// - Import: Clipboard -> parse -> dsBloc.importFromJson()
class DsImportExportWidget extends StatefulWidget {
  const DsImportExportWidget({
    required this.dsBloc,
    super.key,
  });

  final BlocDesignSystem dsBloc;

  @override
  State<DsImportExportWidget> createState() => _DsImportExportWidgetState();
}

class _DsImportExportWidgetState extends State<DsImportExportWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _busy = false;
  String? _localError;
  String? _localInfo;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setInfo(String msg) {
    if (!mounted) {
      return;
    }
    setState(() {
      _localInfo = msg;
      _localError = null;
    });
  }

  void _setError(String msg) {
    if (!mounted) {
      return;
    }
    setState(() {
      _localError = msg;
      _localInfo = null;
    });
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  Future<String> _readFromClipboard() async {
    final ClipboardData? data = await Clipboard.getData('text/plain');
    return (data?.text ?? '').trim();
  }

  String _prettyJson(Object json) {
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(json);
  }

  Future<void> _exportToClipboard() async {
    if (_busy) {
      return;
    }
    setState(() {
      _busy = true;
      _localError = null;
      _localInfo = null;
    });

    try {
      final Map<String, dynamic> json = widget.dsBloc.exportToJson();
      final String pretty = _prettyJson(json);

      await _copyToClipboard(pretty);

      if (!mounted) {
        return;
      }
      _controller.text = pretty;
      _setInfo('DS exportado al portapapeles (${pretty.length} chars).');
    } catch (e) {
      _setError('No se pudo exportar: $e');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _pasteFromClipboardIntoEditor() async {
    if (_busy) {
      return;
    }
    setState(() {
      _busy = true;
      _localError = null;
      _localInfo = null;
    });

    try {
      final String txt = await _readFromClipboard();
      if (txt.isEmpty) {
        _setError('El portapapeles está vacío.');
        return;
      }
      _controller.text = txt;
      _setInfo('Pegado desde portapapeles (${txt.length} chars).');
    } catch (e) {
      _setError('No se pudo leer el portapapeles: $e');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _importFromEditorText() async {
    if (_busy) {
      return;
    }
    setState(() {
      _busy = true;
      _localError = null;
      _localInfo = null;
    });

    try {
      final String raw = _controller.text.trim();
      if (raw.isEmpty) {
        _setError('No hay JSON en el editor.');
        return;
      }

      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        _setError('El JSON debe ser un objeto (Map<String, dynamic>).');
        return;
      }

      widget.dsBloc.importFromJson(decoded);
      _setInfo('DS importado correctamente desde el JSON.');
    } catch (e) {
      _setError('JSON inválido o no importable: $e');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _importDirectlyFromClipboard() async {
    if (_busy) {
      return;
    }
    setState(() {
      _busy = true;
      _localError = null;
      _localInfo = null;
    });

    try {
      final String txt = await _readFromClipboard();
      if (txt.isEmpty) {
        _setError('El portapapeles está vacío.');
        return;
      }

      final Object? decoded = jsonDecode(txt);
      if (decoded is! Map<String, dynamic>) {
        _setError('El JSON del portapapeles debe ser un objeto.');
        return;
      }

      widget.dsBloc.importFromJson(decoded);

      if (!mounted) {
        return;
      }
      _controller.text = _prettyJson(decoded);
      _setInfo('DS importado desde portapapeles.');
    } catch (e) {
      _setError('No se pudo importar desde portapapeles: $e');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  void _clearEditor() {
    _controller.clear();
    _setInfo('Editor limpiado.');
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final ModelDsExtendedTokens tok = context.dsTokens;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(tok.spacingSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Import / Export (JSON)', style: t.textTheme.titleLarge),
            SizedBox(height: tok.spacingXs),
            Text(
              'Copia el DS como JSON al portapapeles o importa pegando un JSON válido.',
              style: t.textTheme.bodySmall,
            ),
            SizedBox(height: tok.spacing),
            Wrap(
              spacing: tok.spacingSm,
              runSpacing: tok.spacingSm,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: _busy ? null : _exportToClipboard,
                  icon: const Icon(Icons.copy),
                  label: const Text('Export → Clipboard'),
                ),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _importDirectlyFromClipboard,
                  icon: const Icon(Icons.content_paste_go),
                  label: const Text('Import ← Clipboard'),
                ),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _pasteFromClipboardIntoEditor,
                  icon: const Icon(Icons.content_paste),
                  label: const Text('Paste → Editor'),
                ),
                OutlinedButton.icon(
                  onPressed: _busy ? null : _importFromEditorText,
                  icon: const Icon(Icons.publish),
                  label: const Text('Import ← Editor'),
                ),
                TextButton.icon(
                  onPressed: _busy ? null : _clearEditor,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Clear'),
                ),
              ],
            ),
            SizedBox(height: tok.spacingSm),
            if (_localError != null)
              _InlineMessage(
                icon: Icons.error_outline,
                text: _localError!,
              )
            else if (_localInfo != null)
              _InlineMessage(
                icon: Icons.info_outline,
                text: _localInfo!,
              ),
            if (_localError != null || _localInfo != null)
              SizedBox(height: tok.spacingSm),
            SizedBox(
              height: 280,
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  labelText: 'DS JSON',
                  hintText: '{ ... }',
                  alignLabelWithHint: true,
                ),
                style: t.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final ModelDsExtendedTokens tok = context.dsTokens;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(tok.spacingSm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(tok.borderRadiusSm),
        border: Border.all(color: t.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18),
          SizedBox(width: tok.spacingSm),
          Expanded(
            child: Text(
              text,
              style: t.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
