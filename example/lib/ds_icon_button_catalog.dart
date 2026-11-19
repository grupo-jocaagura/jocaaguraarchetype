part of 'ds_widget_catalog.dart';

final DsWidgetCatalogEntry _iconButtonEntry = DsWidgetCatalogEntry(
  anatomy: _anatomy(
    'ds.widget.icon_button',
    'DsIconButtonWidget',
    'A circular icon action controlled by its interaction state.',
    const <String>['Give the action a meaningful accessible name.'],
    const <String>['colorScheme', 'semanticColors'],
    slots: const <ModelDsComponentSlot>[
      ModelDsComponentSlot(
        name: 'Target',
        role: 'Reserves 48 × 48 logical pixels for focus and activation.',
        rules: <String>['Leave at least 48 logical pixels on each axis.'],
        tokensUsed: <String>[],
      ),
      ModelDsComponentSlot(
        name: 'Surface',
        role: 'Shows the filled or outlined circular surface at 32 logical pixels.',
        rules: <String>[
          'Use the same semantic color roles as the grid item button.',
        ],
        tokensUsed: <String>['colorScheme', 'semanticColors'],
      ),
      ModelDsComponentSlot(
        name: 'Icon and feedback',
        role: 'Shows the action icon, selection or error marker, or loading indicator.',
        rules: <String>[
          'Keep the accessible action name stable during loading.',
        ],
        tokensUsed: <String>[],
      ),
    ],
  ),
  family: 'Icons',
  snippet: "DsIconButtonWidget(icon: Icons.add, semanticLabel: 'Add item', onPressed: onAdd)",
  preview: _buildIconButtonPreview,
);

Widget _buildIconButtonPreview(BuildContext context) {
  final ModelDsExtendedTokens tokens = context.dsTokens;
  bool selected = false;
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) => Wrap(
      spacing: tokens.spacingSm,
      runSpacing: tokens.spacingSm,
      children: <Widget>[
        const _IconButtonCase(
          caption: 'Filled',
          button: DsIconButtonWidget(
            icon: Icons.add,
            semanticLabel: 'Add item',
            onPressed: _iconButtonNoop,
          ),
        ),
        const _IconButtonCase(
          caption: 'Outlined',
          button: DsIconButtonWidget(
            icon: Icons.close,
            semanticLabel: 'Close panel',
            variant: DsSurfaceVariant.outlined,
            onPressed: _iconButtonNoop,
          ),
        ),
        _IconButtonCase(
          caption: 'Toggle selection',
          button: DsIconButtonWidget(
            icon: Icons.favorite_border,
            selectedIcon: Icons.favorite,
            semanticLabel: 'Toggle favorite',
            state: ModelInteractiveState(isSelected: selected),
            onPressed: () => setState(() => selected = !selected),
          ),
        ),
        const _IconButtonCase(
          caption: 'Selected, blocked',
          button: DsIconButtonWidget(
            icon: Icons.bookmark_border,
            selectedIcon: Icons.bookmark,
            semanticLabel: 'Toggle bookmark',
            state: ModelInteractiveState(
              isEnabled: false,
              isSelected: true,
              reasonText: 'The bookmark is locked.',
            ),
            onPressed: _iconButtonNoop,
          ),
        ),
        const _IconButtonCase(
          caption: 'Loading',
          button: DsIconButtonWidget(
            icon: Icons.sync,
            semanticLabel: 'Sync settings',
            state: ModelInteractiveState(isLoading: true),
            onPressed: _iconButtonNoop,
          ),
        ),
        const _IconButtonCase(
          caption: 'Retry',
          button: DsIconButtonWidget(
            icon: Icons.refresh,
            semanticLabel: 'Retry connection',
            state: ModelInteractiveState(
              errorText: 'Connection failed. Try again.',
            ),
            onPressed: _iconButtonNoop,
          ),
        ),
        for (final (
              String caption,
              IconData icon,
              ModelInteractiveSemantic intent,
            )
            in const <(String, IconData, ModelInteractiveSemantic)>[
              ('Success', Icons.done_all, ModelInteractiveSemantic.success),
              (
                'Warning',
                Icons.warning_amber,
                ModelInteractiveSemantic.warning,
              ),
              ('Danger', Icons.delete_outline, ModelInteractiveSemantic.danger),
            ])
          _IconButtonCase(
            caption: caption,
            button: DsIconButtonWidget(
              icon: icon,
              semanticLabel: caption == 'Danger'
                  ? 'Remove item'
                  : 'Review ${caption.toLowerCase()} details',
              state: ModelInteractiveState(semantic: intent),
              onPressed: _iconButtonNoop,
            ),
          ),
      ],
    ),
  );
}

class _IconButtonCase extends StatelessWidget {
  const _IconButtonCase({required this.caption, required this.button});

  final String caption;
  final DsIconButtonWidget button;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 80,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        button,
        Text(
          caption,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    ),
  );
}

void _iconButtonNoop() {}
