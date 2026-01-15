part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

@immutable
class DsExtendedTokensExtension
    extends ThemeExtension<DsExtendedTokensExtension> {
  const DsExtendedTokensExtension({
    required this.tokens,
  });

  final ModelDsExtendedTokens tokens;

  @override
  DsExtendedTokensExtension copyWith({
    ModelDsExtendedTokens? tokens,
  }) {
    return DsExtendedTokensExtension(
      tokens: tokens ?? this.tokens,
    );
  }

  @override
  DsExtendedTokensExtension lerp(
    ThemeExtension<DsExtendedTokensExtension>? other,
    double time,
  ) {
    if (other is! DsExtendedTokensExtension) {
      return this;
    }
    // Tokens no siempre se “interpolan” bien; el approach seguro:
    return (time < 0.5) ? this : other;
  }
}

extension DsTokensContextX on BuildContext {
  ModelDsExtendedTokens get dsTokens {
    final DsExtendedTokensExtension? ext =
        Theme.of(this).extension<DsExtendedTokensExtension>();
    if (ext == null) {
      throw StateError(
        'Missing DsExtendedTokensExtension in ThemeData.extensions',
      );
    }
    return ext.tokens;
  }
}
