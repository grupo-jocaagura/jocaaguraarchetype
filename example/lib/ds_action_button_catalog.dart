part of 'ds_widget_catalog.dart';

DsWidgetCatalogEntry _actionButtonEntry({required bool primary}) {
  final String name = primary
      ? 'DsPrimaryButtonWidget'
      : 'DsSecondaryButtonWidget';
  return DsWidgetCatalogEntry(
    anatomy: _anatomy(
      primary ? 'ds.widget.primary_button' : 'ds.widget.secondary_button',
      name,
      primary
          ? 'Filled button for the main action in a section.'
          : 'Outlined button for a supporting action, such as canceling.',
      const <String>[
        'Provide a localized action label. An optional leading icon is decorative.',
        'Allow a 48 × 48 logical-pixel target and room for multiline labels.',
        'Control selection, loading and availability through ModelInteractiveState.',
      ],
      const <String>['textTheme.labelLarge', 'colorScheme', 'semanticColors'],
      slots: const <ModelDsComponentSlot>[
        ModelDsComponentSlot(
          name: 'Label',
          role: 'Names the action and wraps at the available width.',
          rules: <String>['Use a short, localized action phrase.'],
          tokensUsed: <String>['textTheme.labelLarge'],
        ),
        ModelDsComponentSlot(
          name: 'Leading slot',
          role: 'Shows an optional icon, state marker or loading indicator.',
          rules: <String>['The action label stays visible during loading.'],
          tokensUsed: <String>['spacing', 'spacingXs'],
        ),
      ],
    ),
    family: 'Buttons',
    snippet:
        "DsPrimaryButtonWidget(label: 'Guardar', icon: Icons.save, onPressed: save)\n"
        "DsSecondaryButtonWidget(label: 'Cancelar', onPressed: cancel)",
    preview: (BuildContext context) =>
        _buildActionButtonPreview(context, primary: primary),
  );
}

Widget _buildActionButtonPreview(
  BuildContext context, {
  required bool primary,
}) {
  final ModelDsExtendedTokens tokens = context.dsTokens;
  final ModelInteractiveSemantic intent = primary
      ? ModelInteractiveSemantic.primary
      : ModelInteractiveSemantic.secondary;

  Widget button(
    String label, {
    VoidCallback? onPressed,
    IconData? icon,
    ModelInteractiveState? state,
  }) {
    final ModelInteractiveState resolvedState =
        state ?? ModelInteractiveState(semantic: intent);
    return primary
        ? DsPrimaryButtonWidget(
            label: label,
            icon: icon,
            state: resolvedState,
            onPressed: onPressed ?? _previewAction,
          )
        : DsSecondaryButtonWidget(
            label: label,
            icon: icon,
            state: resolvedState,
            onPressed: onPressed ?? _previewAction,
          );
  }

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Wrap(
        spacing: tokens.spacingSm,
        runSpacing: tokens.spacingSm,
        children: <Widget>[
          DsPrimaryButtonWidget(
            label: 'Guardar',
            icon: Icons.save_outlined,
            onPressed: () => _showActionFeedback(context, 'Guardado'),
          ),
          DsSecondaryButtonWidget(
            label: 'Cancelar',
            onPressed: () => _showActionFeedback(context, 'Cancelado'),
          ),
        ],
      ),
      SizedBox(height: tokens.spacing),
      Wrap(
        spacing: tokens.spacingSm,
        runSpacing: tokens.spacingSm,
        children: <Widget>[
          button(
            'Compartir',
            icon: Icons.share_outlined,
            onPressed: () => _showActionFeedback(context, 'Compartido'),
          ),
          button(
            'Seleccionado',
            state: ModelInteractiveState(semantic: intent, isSelected: true),
          ),
          button(
            'Guardando cambios',
            state: ModelInteractiveState(semantic: intent, isLoading: true),
          ),
          button(
            'Continuar',
            state: ModelInteractiveState(
              semantic: intent,
              isEnabled: false,
              reasonText: 'Completa los datos para continuar.',
            ),
          ),
          button(
            'Reintentar',
            state: ModelInteractiveState(
              semantic: intent,
              errorText: 'Falló la conexión.',
            ),
            onPressed: () => _showActionFeedback(context, 'Reintento iniciado'),
          ),
          button(
            'Confirmar pago',
            state: const ModelInteractiveState(
              semantic: ModelInteractiveSemantic.success,
            ),
          ),
          button(
            'Revisar cambios',
            state: const ModelInteractiveState(
              semantic: ModelInteractiveSemantic.warning,
            ),
          ),
          button(
            'Eliminar archivo',
            state: const ModelInteractiveState(
              semantic: ModelInteractiveSemantic.danger,
            ),
          ),
        ],
      ),
      SizedBox(height: tokens.spacing),
      const Text('Texto ampliado al 200 %'),
      SizedBox(height: tokens.spacingXs),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 220),
        child: MediaQuery.withClampedTextScaling(
          minScaleFactor: 2,
          maxScaleFactor: 2,
          child: button('Descargar todos los comprobantes'),
        ),
      ),
    ],
  );
}

void _previewAction() {}

void _showActionFeedback(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
