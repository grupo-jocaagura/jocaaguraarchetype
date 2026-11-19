part of 'ds_widget_catalog.dart';

final List<DsWidgetCatalogEntry> _itemFamilyEntries = <DsWidgetCatalogEntry>[
  _textRoleEntry(
    'ds.widget.text_display_large',
    'DsTextDisplayLargeWidget',
    'displayLarge',
    'A short hero message with generous space.',
    const DsTextDisplayLargeWidget(label: 'Explore'),
    'Explore',
  ),
  _textRoleEntry(
    'ds.widget.text_display_medium',
    'DsTextDisplayMediumWidget',
    'displayMedium',
    'A prominent campaign statement.',
    const DsTextDisplayMediumWidget(label: 'Discover'),
    'Discover',
  ),
  _textRoleEntry(
    'ds.widget.text_display_small',
    'DsTextDisplaySmallWidget',
    'displaySmall',
    'A compact hero or featured metric.',
    const DsTextDisplaySmallWidget(label: 'Design together'),
    'Design together',
  ),
  _textRoleEntry(
    'ds.widget.text_headline_large',
    'DsTextHeadlineLargeWidget',
    'headlineLarge',
    'A primary page heading.',
    const DsTextHeadlineLargeWidget(label: 'Dashboard'),
    'Dashboard',
  ),
  _textRoleEntry(
    'ds.widget.text_headline_medium',
    'DsTextHeadlineMediumWidget',
    'headlineMedium',
    'A section heading.',
    const DsTextHeadlineMediumWidget(label: 'Recent activity'),
    'Recent activity',
  ),
  _textRoleEntry(
    'ds.widget.text_headline_small',
    'DsTextHeadlineSmallWidget',
    'headlineSmall',
    'A subsection heading.',
    const DsTextHeadlineSmallWidget(label: 'Next steps'),
    'Next steps',
  ),
  _textRoleEntry(
    'ds.widget.text_title_large',
    'DsTextTitleLargeWidget',
    'titleLarge',
    'A prominent content title.',
    const DsTextTitleLargeWidget(label: 'Account overview'),
    'Account overview',
  ),
  _textRoleEntry(
    'ds.widget.text_title_medium',
    'DsTextTitleMediumWidget',
    'titleMedium',
    'A card or list group title.',
    const DsTextTitleMediumWidget(label: 'Monthly report'),
    'Monthly report',
  ),
  _textRoleEntry(
    'ds.widget.text_title_small',
    'DsTextTitleSmallWidget',
    'titleSmall',
    'A compact component title.',
    const DsTextTitleSmallWidget(label: 'Account details'),
    'Account details',
  ),
  _textRoleEntry(
    'ds.widget.text_body_large',
    'DsTextBodyLargeWidget',
    'bodyLarge',
    'Emphasized reading copy.',
    const DsTextBodyLargeWidget(label: 'Read the highlights'),
    'Read the highlights',
  ),
  _textRoleEntry(
    'ds.widget.text_body_medium',
    'DsTextBodyMediumWidget',
    'bodyMedium',
    'Standard reading copy.',
    const DsTextBodyMediumWidget(label: 'Your changes were saved.'),
    'Your changes were saved.',
  ),
  _textRoleEntry(
    'ds.widget.text_body_small',
    'DsTextBodySmallWidget',
    'bodySmall',
    'Secondary supporting copy.',
    const DsTextBodySmallWidget(label: 'Updated yesterday'),
    'Updated yesterday',
  ),
  _textRoleEntry(
    'ds.widget.text_label_large',
    'DsTextLabelLargeWidget',
    'labelLarge',
    'A prominent control label.',
    const DsTextLabelLargeWidget(label: 'Continue'),
    'Continue',
  ),
  _textRoleEntry(
    'ds.widget.text_label_medium',
    'DsTextLabelMediumWidget',
    'labelMedium',
    'A compact grid item label.',
    const DsTextLabelMediumWidget(label: 'Favorites'),
    'Favorites',
  ),
  _textRoleEntry(
    'ds.widget.text_label_small',
    'DsTextLabelSmallWidget',
    'labelSmall',
    'A badge or small metadata label.',
    const DsTextLabelSmallWidget(label: 'New'),
    'New',
  ),
  DsWidgetCatalogEntry(
    anatomy: _anatomy(
      'ds.widget.ds_inline_text',
      'DsInlineTextWidget',
      'Responsive inline text with a selectable theme role.',
      const <String>['Give short text a bounded width.'],
      const <String>['textTheme', 'MediaQuery.textScaler'],
    ),
    family: 'DS Typography',
    snippet:
        "DsInlineTextWidget(label: 'Status', role: DsTextStyleKey.labelLarge)",
    preview: (_) => const DsInlineTextWidget(
      label: 'Status',
      role: DsTextStyleKey.labelLarge,
    ),
  ),
  DsWidgetCatalogEntry(
    anatomy: _anatomy(
      'ds.widget.text_paragraph',
      'DsTextParagraphWidget',
      'Responsive multiline copy with a preset or explicit theme role.',
      const <String>[
        'Give paragraphs bounded width and enough height for the line budget.',
      ],
      const <String>[
        'textTheme.bodyMedium',
        'textTheme.bodySmall',
        'textTheme.headlineMedium',
      ],
    ),
    family: 'DS Typography',
    snippet:
        "DsTextParagraphWidget(label: 'Your changes were saved.', maxLines: 2)",
    preview: (BuildContext context) => const DsTextParagraphWidget(
      label: 'Your changes were saved. You can return to this page later.',
      maxLines: 3,
    ),
  ),
  DsWidgetCatalogEntry(
    anatomy: _anatomy(
      'ds.widget.loading',
      'DsLoadingWidget',
      'An indeterminate indicator using the active progress theme.',
      const <String>[
        'Use while work is in progress and the duration is unknown.',
      ],
      const <String>['spacingLg', 'spacingXs', 'progressIndicatorTheme'],
    ),
    family: 'Grid items',
    snippet: "DsLoadingWidget(semanticLabel: 'Loading results')",
    preview: (_) =>
        const Center(child: DsLoadingWidget(semanticLabel: 'Loading results')),
  ),
  DsWidgetCatalogEntry(
    anatomy: _anatomy(
      'ds.widget.item',
      'DsItemWidget',
      'Passive grid surface with a compact size and a label that can wrap.',
      const <String>[
        'Keep the visual slot passive.',
        'Use short labels or reserve more room.',
      ],
      const <String>['spacingXXl', 'borderRadius', 'textTheme.labelMedium'],
      slots: const <ModelDsComponentSlot>[
        ModelDsComponentSlot(
          name: 'Visual',
          role: 'Holds a compact icon, illustration or short value.',
          rules: <String>['Use passive content that fits the allocated area.'],
          tokensUsed: <String>['spacingSm'],
        ),
        ModelDsComponentSlot(
          name: 'Label',
          role: 'Names the item using DsTextParagraphWidget with labelMedium.',
          rules: <String>[
            'Allow more height when a label needs several lines.',
          ],
          tokensUsed: <String>['spacingXs', 'textTheme.labelMedium'],
        ),
      ],
    ),
    family: 'Grid items',
    snippet: "DsItemWidget(label: 'Favorites', child: DsIconWidget(icon: Icons.star))",
    preview: _passiveItemsPreview,
  ),
  DsWidgetCatalogEntry(
    anatomy: _anatomy(
      'ds.widget.item_button',
      'DsItemButtonWidget',
      'Controlled grid action with theme variants, feedback and loading.',
      const <String>['Use the state model to control activation.'],
      const <String>['colorScheme', 'semanticColors', 'spacingLg'],
      slots: const <ModelDsComponentSlot>[
        ModelDsComponentSlot(
          name: 'Surface',
          role: 'Shows the same content and layout as the passive grid item.',
          rules: <String>[
            'Apply the variant and semantic intent from the active theme.',
          ],
          tokensUsed: <String>['colorScheme', 'semanticColors', 'borderRadius'],
        ),
        ModelDsComponentSlot(
          name: 'Action',
          role: 'Exposes one named control for pointer, keyboard and assistive technology.',
          rules: <String>[
            'Allow activation only when state.canInteract is true.',
          ],
          tokensUsed: <String>[],
        ),
        ModelDsComponentSlot(
          name: 'Loading',
          role: 'Replaces the visual content while the action is in progress.',
          rules: <String>['Keep the label in place and bound the indicator.'],
          tokensUsed: <String>['spacingLg'],
        ),
      ],
    ),
    family: 'Grid items',
    snippet: "DsItemButtonWidget(label: 'Open', onPressed: onOpen, child: DsIconWidget(icon: Icons.folder))",
    preview: _itemButtonsPreview,
  ),
];

DsWidgetCatalogEntry _textRoleEntry(
  String id,
  String name,
  String role,
  String description,
  Widget sample,
  String copy,
) => DsWidgetCatalogEntry(
  anatomy: _anatomy(
    id,
    name,
    description,
    const <String>[
      'Use the effective TextTheme and provide bounded width for fitting.',
    ],
    <String>['textTheme.$role', 'MediaQuery.textScaler'],
  ),
  family: 'DS Typography',
  snippet: "$name(label: '$copy')",
  preview: (_) => sample,
);

Widget _passiveItemsPreview(BuildContext context) {
  final ModelDsExtendedTokens tokens = context.dsTokens;
  return Wrap(
    spacing: tokens.spacingSm,
    runSpacing: tokens.spacingSm,
    children: <Widget>[
      const _ItemPreviewCase(
        caption: 'Short label · default size',
        child: DsItemWidget(
          label: 'Open',
          child: DsIconWidget(icon: Icons.star),
        ),
      ),
      const _ItemPreviewCase(
        caption: 'Outlined · default size',
        child: DsItemWidget(
          label: 'Saved',
          variant: DsSurfaceVariant.outlined,
          child: DsIconWidget(icon: Icons.bookmark_outline),
        ),
      ),
      for (final bool fixed in <bool>[false, true])
        _ItemPreviewCase(
          caption: fixed ? '2× · fixed height' : '2× · flexible height',
          child: MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: fixed ? tokens.spacingXXl : double.infinity,
              ),
              child: DsItemWidget(
                size: Size(
                  2 * tokens.spacingXXl + tokens.spacingXl,
                  tokens.spacingXXl,
                ),
                label: 'Notification settings',
                child: const DsIconWidget(icon: Icons.notifications_outlined),
              ),
            ),
          ),
        ),
    ],
  );
}

class _ItemPreviewCase extends StatelessWidget {
  const _ItemPreviewCase({required this.caption, required this.child});

  final String caption;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(caption, style: Theme.of(context).textTheme.labelSmall),
      SizedBox(height: context.dsTokens.spacingXs),
      child,
    ],
  );
}

Widget _itemButtonsPreview(BuildContext context) {
  final ModelDsExtendedTokens tokens = context.dsTokens;
  bool selected = false;
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) => Wrap(
      spacing: tokens.spacingSm,
      runSpacing: tokens.spacingSm,
      children: <Widget>[
        DsItemButtonWidget(
          label: 'Select',
          state: ModelInteractiveState(isSelected: selected),
          onPressed: () => setState(() => selected = !selected),
          child: const DsIconWidget(icon: Icons.star),
        ),
        const DsItemButtonWidget(
          label: 'Ready',
          variant: DsSurfaceVariant.outlined,
          state: ModelInteractiveState(
            semantic: ModelInteractiveSemantic.success,
          ),
          onPressed: _previewNoop,
          child: DsIconWidget(icon: Icons.task_alt),
        ),
        const DsItemButtonWidget(
          label: 'Review',
          state: ModelInteractiveState(
            semantic: ModelInteractiveSemantic.warning,
          ),
          onPressed: _previewNoop,
          child: DsIconWidget(icon: Icons.warning_amber),
        ),
        const DsItemButtonWidget(
          label: 'Remove',
          state: ModelInteractiveState(
            semantic: ModelInteractiveSemantic.danger,
          ),
          onPressed: _previewNoop,
          child: DsIconWidget(icon: Icons.delete_outline),
        ),
        const DsItemButtonWidget(
          label: 'Saving',
          state: ModelInteractiveState(isLoading: true),
          onPressed: _previewNoop,
          child: DsIconWidget(icon: Icons.save),
        ),
        const DsItemButtonWidget(
          label: 'Locked',
          variant: DsSurfaceVariant.outlined,
          state: ModelInteractiveState(isEnabled: false, isSelected: true),
          onPressed: _previewNoop,
          child: DsIconWidget(icon: Icons.lock_outline),
        ),
        const DsItemButtonWidget(
          label: 'Retry',
          state: ModelInteractiveState(
            errorText: 'The example can be retried.',
          ),
          onPressed: _previewNoop,
          child: DsIconWidget(icon: Icons.refresh),
        ),
      ],
    ),
  );
}

void _previewNoop() {}
