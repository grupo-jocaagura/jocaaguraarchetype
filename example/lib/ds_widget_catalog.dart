import 'dart:async';

import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
import 'package:material_ui/material_ui.dart';

part 'ds_action_button_catalog.dart';
part 'ds_checkbox_field_catalog.dart';
part 'ds_chips_select_catalog.dart';
part 'ds_date_input_catalog.dart';
part 'ds_date_range_input_catalog.dart';
part 'ds_dropdown_button_catalog.dart';
part 'ds_email_input_catalog.dart';
part 'ds_form_actions_catalog.dart';
part 'ds_form_stepper_catalog.dart';
part 'ds_number_input_catalog.dart';
part 'ds_password_input_catalog.dart';
part 'ds_radio_group_field_catalog.dart';
part 'ds_select_input_catalog.dart';
part 'ds_switch_field_catalog.dart';
part 'ds_text_input_catalog.dart';
part 'ds_time_input_catalog.dart';
part 'ds_item_family_catalog.dart';
part 'ds_icon_button_catalog.dart';

/// Local documentation and executable previews share the same stable IDs.
class DsWidgetCatalogEntry {
  const DsWidgetCatalogEntry({
    required this.anatomy,
    required this.family,
    required this.snippet,
    required this.preview,
  });

  final ModelDsComponentAnatomy anatomy;
  final String family;
  final String snippet;
  final GalleryPreviewBuilder preview;

  ModelDsGalleryPageEntry toPage() => ModelDsGalleryPageEntry(
    id: anatomy.id,
    title: anatomy.name,
    section: family,
    description: anatomy.description,
    builder:
        (BuildContext context, BlocGallery bloc, ModelDsGalleryState state) {
          return DesignSystemGalleryPage(
            anatomy: anatomy,
            designSystem: state.designSystem,
            previewBuilder: (BuildContext context) => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  preview(context),
                  SizedBox(height: context.dsTokens.spacing),
                  const Text('Usage'),
                  SelectableText(snippet),
                ],
              ),
            ),
          );
        },
  );
}

ModelDsComponentAnatomy _anatomy(
  String id,
  String name,
  String description,
  List<String> rules,
  List<String> tokens, {
  List<ModelDsComponentSlot>? slots,
}) => ModelDsComponentAnatomy(
  id: id,
  name: name,
  description: description,
  tags: const <String>['public-api', 'widget'],
  status: ModelDsComponentStatusEnum.stable,
  platforms: ModelDsComponentPlatformEnum.values,
  urlDetailedInfo: 'doc/ds-widget-index.md#$id',
  slots:
      slots ??
      <ModelDsComponentSlot>[
        ModelDsComponentSlot(
          name: 'Content',
          role: description,
          rules: rules,
          tokensUsed: tokens,
        ),
      ],
);

/// Public additions; existing surfaces and interaction states use built-in pages.
final List<DsWidgetCatalogEntry> dsWidgetCatalog = <DsWidgetCatalogEntry>[
  ..._itemFamilyEntries,
  DsWidgetCatalogEntry(
    anatomy: _anatomy(
      'ds.widget.icon',
      'DsIconWidget',
      'Passive icons: decorative, informational and explicit appearance.',
      <String>[
        'Appearance priority: explicit, inherited IconTheme, then DS/theme.',
        'Size must be finite and positive.',
        'A nonblank semanticLabel exposes one image node. No input handling.',
      ],
      <String>['spacing', 'iconTheme', 'colorScheme.onSurface'],
    ),
    family: 'Icons',
    snippet:
        "const DsIconWidget(icon: Icons.info, semanticLabel: 'Information')",
    preview: _iconPreview,
  ),
  _iconButtonEntry,
  _actionButtonEntry(primary: true),
  _actionButtonEntry(primary: false),
  _dropdownButtonEntry,
  _selectInputEntry,
  _radioGroupFieldEntry,
  _chipsSelectEntry,
  _checkboxFieldEntry,
  _switchFieldEntry,
  _textInputEntry,
  _passwordInputEntry,
  _emailInputEntry,
  _numberInputEntry,
  _dateInputEntry,
  _dateRangeInputEntry,
  _timeInputEntry,
  _formStepperEntry,
  _formActionsEntry,
  DsWidgetCatalogEntry(
    anatomy: _anatomy(
      'ds.widget.text_responsive',
      'TextResponsiveWidget',
      'Reexported text_responsive widget: fits text inside bounded space.',
      _textRules,
      <String>['textTheme', 'DefaultTextStyle', 'MediaQuery.textScaler'],
    ),
    family: 'Responsive typography (reexported)',
    snippet:
        'SizedBox(width: 180, height: 48, child: TextResponsiveWidget(\n'
        "  child: Text('A long responsive heading', maxLines: 1)))",
    preview: (BuildContext context) => SizedBox(
      height: 48,
      child: TextResponsiveWidget(
        child: Text(
          'A long responsive heading',
          maxLines: 1,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    ),
  ),
  DsWidgetCatalogEntry(
    anatomy: _anatomy(
      'ds.widget.paragraph_text',
      'ParagraphTextWidget',
      'Reexported paragraph text with an explicit line budget.',
      _textRules,
      <String>['textTheme.bodyMedium', 'MediaQuery.textScaler'],
    ),
    family: 'Responsive typography (reexported)',
    snippet:
        'const SizedBox(height: 80, child: ParagraphTextWidget(\n'
        "  'A paragraph that adapts to its available space.', maxLines: 3))",
    preview: (BuildContext context) => SizedBox(
      height: 80,
      child: ParagraphTextWidget(
        'A paragraph that adapts to its available space. '
        'The theme supplies typography in both light and dark previews.',
        maxLines: 3,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    ),
  ),
  DsWidgetCatalogEntry(
    anatomy: _anatomy(
      'ds.widget.inline_text',
      'InlineTextWidget',
      'Reexported compact responsive label.',
      _textRules,
      <String>['textTheme.labelLarge', 'MediaQuery.textScaler'],
    ),
    family: 'Responsive typography (reexported)',
    snippet:
        "const SizedBox(height: 32, child: InlineTextWidget('Compact label'))",
    preview: (BuildContext context) => SizedBox(
      height: 32,
      child: InlineTextWidget(
        'Compact label',
        style: Theme.of(context).textTheme.labelLarge,
      ),
    ),
  ),
];

Widget _iconPreview(BuildContext context) {
  final ModelDsExtendedTokens tokens = context.dsTokens;
  final ThemeData theme = Theme.of(context);
  return IconTheme(
    data: IconTheme.of(context).copyWith(size: tokens.spacingXl),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _IconPreviewCase(
          label: 'Decorativo',
          icon: DsIconWidget(icon: Icons.star),
        ),
        SizedBox(height: tokens.spacingLg),
        const _IconPreviewCase(
          label: 'Informativo',
          icon: DsIconWidget(icon: Icons.info, semanticLabel: 'Información'),
        ),
        SizedBox(height: tokens.spacingLg),
        _IconPreviewCase(
          label: 'Tamaño y color explícitos',
          icon: DsIconWidget(
            icon: Icons.favorite,
            size: tokens.spacingXXl,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    ),
  );
}

class _IconPreviewCase extends StatelessWidget {
  const _IconPreviewCase({required this.label, required this.icon});

  final String label;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tokens = context.dsTokens;
    final Widget caption = Text(
      label,
      style: Theme.of(context).textTheme.labelLarge,
    );
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < tokens.spacingXXl * 3) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              icon,
              SizedBox(height: tokens.spacingSm),
              caption,
            ],
          );
        }
        return Row(
          children: <Widget>[
            SizedBox(
              width: tokens.spacingXXl,
              child: Center(child: icon),
            ),
            SizedBox(width: tokens.spacing),
            Expanded(child: caption),
          ],
        );
      },
    );
  }
}

const List<String> _textRules = <String>[
  'Provide bounded space and an appropriate line budget.',
  'At the effective minimum the text can still overflow; reserve enough space.',
  'Explicit overflow and WidgetSpan delegate layout to Flutter without shrinking.',
  'Preserve reading direction, accessibility labels and user text scaling.',
];
