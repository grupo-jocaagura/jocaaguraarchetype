part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// One-line responsive text using a role from the nearest [TextTheme].
///
/// Provide a bounded width to enable fitting. An explicit overflow policy
/// delegates layout to Flutter. Use [semanticLabel] for an accessible
/// alternative; heading semantics belong to the containing layout.
class DsInlineTextWidget extends StatelessWidget {
  const DsInlineTextWidget({
    required this.label,
    this.role = DsTextStyleKey.bodyMedium,
    this.textAlign,
    this.overflow,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final DsTextStyleKey role;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => DefaultTextStyle.merge(
    maxLines: 1,
    softWrap: false,
    child: InlineTextWidget(
      label,
      style: role.get(Theme.of(context).textTheme),
      textAlign: textAlign,
      overflow: overflow,
      semanticsLabel: semanticLabel,
    ),
  );
}

/// Text roles for paragraphs with a finite line budget.
enum DsTextParagraphStyle {
  /// Standard reading copy, using [TextTheme.bodyMedium].
  normal(DsTextStyleKey.bodyMedium),

  /// Supporting copy, using [TextTheme.bodySmall].
  detail(DsTextStyleKey.bodySmall),

  /// A multiline heading, using [TextTheme.headlineMedium].
  display(DsTextStyleKey.headlineMedium);

  const DsTextParagraphStyle(this.role);

  final DsTextStyleKey role;
}

/// Responsive multiline copy using the active [TextTheme] and text scaling.
class DsTextParagraphWidget extends StatelessWidget {
  const DsTextParagraphWidget({
    required this.label,
    this.paragraphStyle = DsTextParagraphStyle.normal,
    this.role,
    this.maxLines = 2,
    this.textAlign,
    this.overflow,
    this.semanticLabel,
    super.key,
  }) : assert(maxLines > 0);

  final String label;
  final DsTextParagraphStyle paragraphStyle;

  /// Explicit theme role. When omitted, [paragraphStyle] selects the role.
  final DsTextStyleKey? role;

  final int maxLines;
  final TextAlign? textAlign;

  /// An explicit policy keeps Flutter in charge of overflow instead of fitting.
  final TextOverflow? overflow;

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => ParagraphTextWidget(
    label,
    maxLines: maxLines,
    style: (role ?? paragraphStyle.role).get(Theme.of(context).textTheme),
    textAlign: textAlign,
    overflow: overflow,
    semanticsLabel: semanticLabel,
  );
}

/// The [TextTheme.displayLarge] role for a hero message.
class DsTextDisplayLargeWidget extends DsInlineTextWidget {
  const DsTextDisplayLargeWidget({
    required super.label,
    super.textAlign,
    super.overflow,
    super.semanticLabel,
    super.key,
  }) : super(role: DsTextStyleKey.displayLarge);
}

/// The [TextTheme.displayMedium] role for a prominent campaign message.
class DsTextDisplayMediumWidget extends DsInlineTextWidget {
  const DsTextDisplayMediumWidget({
    required super.label,
    super.textAlign,
    super.overflow,
    super.semanticLabel,
    super.key,
  }) : super(role: DsTextStyleKey.displayMedium);
}

/// The [TextTheme.displaySmall] role for a compact hero message.
class DsTextDisplaySmallWidget extends DsInlineTextWidget {
  const DsTextDisplaySmallWidget({
    required super.label,
    super.textAlign,
    super.overflow,
    super.semanticLabel,
    super.key,
  }) : super(role: DsTextStyleKey.displaySmall);
}

/// The [TextTheme.headlineLarge] role for a page heading.
class DsTextHeadlineLargeWidget extends DsInlineTextWidget {
  const DsTextHeadlineLargeWidget({
    required super.label,
    super.textAlign,
    super.overflow,
    super.semanticLabel,
    super.key,
  }) : super(role: DsTextStyleKey.headlineLarge);
}

/// The [TextTheme.headlineMedium] role for a section heading.
class DsTextHeadlineMediumWidget extends DsInlineTextWidget {
  const DsTextHeadlineMediumWidget({
    required super.label,
    super.textAlign,
    super.overflow,
    super.semanticLabel,
    super.key,
  }) : super(role: DsTextStyleKey.headlineMedium);
}

/// The [TextTheme.headlineSmall] role for a subsection heading.
class DsTextHeadlineSmallWidget extends DsInlineTextWidget {
  const DsTextHeadlineSmallWidget({
    required super.label,
    super.textAlign,
    super.overflow,
    super.semanticLabel,
    super.key,
  }) : super(role: DsTextStyleKey.headlineSmall);
}

/// The [TextTheme.titleLarge] role for a prominent content title.
class DsTextTitleLargeWidget extends DsInlineTextWidget {
  const DsTextTitleLargeWidget({
    required super.label,
    super.textAlign,
    super.overflow,
    super.semanticLabel,
    super.key,
  }) : super(role: DsTextStyleKey.titleLarge);
}

/// The [TextTheme.titleMedium] role for a card or list group title.
class DsTextTitleMediumWidget extends DsInlineTextWidget {
  const DsTextTitleMediumWidget({
    required super.label,
    super.textAlign,
    super.overflow,
    super.semanticLabel,
    super.key,
  }) : super(role: DsTextStyleKey.titleMedium);
}

/// The [TextTheme.titleSmall] role for a compact component title.
class DsTextTitleSmallWidget extends DsInlineTextWidget {
  const DsTextTitleSmallWidget({
    required super.label,
    super.textAlign,
    super.overflow,
    super.semanticLabel,
    super.key,
  }) : super(role: DsTextStyleKey.titleSmall);
}

/// The [TextTheme.bodyLarge] role for emphasized reading copy.
class DsTextBodyLargeWidget extends DsInlineTextWidget {
  const DsTextBodyLargeWidget({
    required super.label,
    super.textAlign,
    super.overflow,
    super.semanticLabel,
    super.key,
  }) : super(role: DsTextStyleKey.bodyLarge);
}

/// The [TextTheme.bodyMedium] role for standard reading copy.
class DsTextBodyMediumWidget extends DsInlineTextWidget {
  const DsTextBodyMediumWidget({
    required super.label,
    super.textAlign,
    super.overflow,
    super.semanticLabel,
    super.key,
  }) : super(role: DsTextStyleKey.bodyMedium);
}

/// The [TextTheme.bodySmall] role for secondary supporting copy.
class DsTextBodySmallWidget extends DsInlineTextWidget {
  const DsTextBodySmallWidget({
    required super.label,
    super.textAlign,
    super.overflow,
    super.semanticLabel,
    super.key,
  }) : super(role: DsTextStyleKey.bodySmall);
}

/// The [TextTheme.labelLarge] role for a prominent control label.
class DsTextLabelLargeWidget extends DsInlineTextWidget {
  const DsTextLabelLargeWidget({
    required super.label,
    super.textAlign,
    super.overflow,
    super.semanticLabel,
    super.key,
  }) : super(role: DsTextStyleKey.labelLarge);
}

/// The [TextTheme.labelMedium] role for a compact grid item label.
class DsTextLabelMediumWidget extends DsInlineTextWidget {
  const DsTextLabelMediumWidget({
    required super.label,
    super.textAlign,
    super.overflow,
    super.semanticLabel,
    super.key,
  }) : super(role: DsTextStyleKey.labelMedium);
}

/// The [TextTheme.labelSmall] role for a badge or small metadata label.
class DsTextLabelSmallWidget extends DsInlineTextWidget {
  const DsTextLabelSmallWidget({
    required super.label,
    super.textAlign,
    super.overflow,
    super.semanticLabel,
    super.key,
  }) : super(role: DsTextStyleKey.labelSmall);
}
