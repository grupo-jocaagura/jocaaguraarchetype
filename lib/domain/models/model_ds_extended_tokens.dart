part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

abstract class ModelDsExtendedTokensKeys {
  static const String spacingXs = 'spacingXs';
  static const String spacingSm = 'spacingSm';
  static const String spacing = 'spacing';
  static const String spacingLg = 'spacingLg';
  static const String spacingXl = 'spacingXl';
  static const String spacingXXl = 'spacingXXl';

  static const String borderRadiusXs = 'borderRadiusXs';
  static const String borderRadiusSm = 'borderRadiusSm';
  static const String borderRadius = 'borderRadius';
  static const String borderRadiusLg = 'borderRadiusLg';
  static const String borderRadiusXl = 'borderRadiusXl';
  static const String borderRadiusXXl = 'borderRadiusXXl';

  static const String elevationXs = 'elevationXs';
  static const String elevationSm = 'elevationSm';
  static const String elevation = 'elevation';
  static const String elevationLg = 'elevationLg';
  static const String elevationXl = 'elevationXl';
  static const String elevationXXl = 'elevationXXl';

  static const String withAlphaXs = 'withAlphaXs';
  static const String withAlphaSm = 'withAlphaSm';
  static const String withAlpha = 'withAlpha';
  static const String withAlphaLg = 'withAlphaLg';
  static const String withAlphaXl = 'withAlphaXl';
  static const String withAlphaXXl = 'withAlphaXXl';

  static const String animationDurationShort = 'animationDurationShort';
  static const String animationDuration = 'animationDuration';
  static const String animationDurationLong = 'animationDurationLong';
}

class ModelDsExtendedTokens {
  const ModelDsExtendedTokens({
    this.spacingXs = 4.0,
    this.spacingSm = 8.0,
    this.spacing = 16.0,
    this.spacingLg = 24.0,
    this.spacingXl = 32.0,
    this.spacingXXl = 64.0,
    this.borderRadiusXs = 2.0,
    this.borderRadiusSm = 4.0,
    this.borderRadius = 8.0,
    this.borderRadiusLg = 12.0,
    this.borderRadiusXl = 16.0,
    this.borderRadiusXXl = 24.0,
    this.elevationXs = 0.0,
    this.elevationSm = 1.0,
    this.elevation = 3.0,
    this.elevationLg = 6.0,
    this.elevationXl = 12.0,
    this.elevationXXl = 16.0,
    this.withAlphaXs = 0.04,
    this.withAlphaSm = 0.12,
    this.withAlpha = 0.16,
    this.withAlphaLg = 0.24,
    this.withAlphaXl = 0.32,
    this.withAlphaXXl = 0.40,
    this.animationDurationShort = const Duration(milliseconds: 100),
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationDurationLong = const Duration(milliseconds: 800),
  });

  factory ModelDsExtendedTokens.fromFactor({
    double spacingFactor = 2.0,
    double initialSpacing = 4.0,
    double borderRadiusFactor = 2.0,
    double initialBorderRadius = 2.0,
    double elevationFactor = 2.0,
    double initialElevation = 1.0,
    double alphaFactor = 0.8,
    double initialAlpha = 0.96,
    int animationDurationFactor = 3,
    double initialAnimationDuration = 100.0,
  }) {
    return ModelDsExtendedTokens(
      spacingXs: initialSpacing,
      spacingSm: initialSpacing * spacingFactor,
      spacing: initialSpacing * spacingFactor * spacingFactor,
      spacingLg: initialSpacing * spacingFactor * spacingFactor * spacingFactor,
      spacingXl: initialSpacing *
          spacingFactor *
          spacingFactor *
          spacingFactor *
          spacingFactor,
      spacingXXl: initialSpacing *
          spacingFactor *
          spacingFactor *
          spacingFactor *
          spacingFactor *
          spacingFactor,
      borderRadiusXs: initialBorderRadius,
      borderRadiusSm: initialBorderRadius * borderRadiusFactor,
      borderRadius:
          initialBorderRadius * borderRadiusFactor * borderRadiusFactor,
      borderRadiusLg: initialBorderRadius *
          borderRadiusFactor *
          borderRadiusFactor *
          borderRadiusFactor,
      borderRadiusXl: initialBorderRadius *
          borderRadiusFactor *
          borderRadiusFactor *
          borderRadiusFactor *
          borderRadiusFactor,
      borderRadiusXXl: initialBorderRadius *
          borderRadiusFactor *
          borderRadiusFactor *
          borderRadiusFactor *
          borderRadiusFactor *
          borderRadiusFactor,
      elevationXs: initialElevation,
      elevationSm: initialElevation * elevationFactor,
      elevation: initialElevation * elevationFactor * elevationFactor,
      elevationLg: initialElevation *
          elevationFactor *
          elevationFactor *
          elevationFactor,
      elevationXl: initialElevation *
          elevationFactor *
          elevationFactor *
          elevationFactor *
          elevationFactor,
      elevationXXl: initialElevation *
          elevationFactor *
          elevationFactor *
          elevationFactor *
          elevationFactor *
          elevationFactor,
      withAlphaXs: initialAlpha,
      withAlphaSm: initialAlpha * alphaFactor,
      withAlpha: initialAlpha * alphaFactor * alphaFactor,
      withAlphaLg: initialAlpha * alphaFactor * alphaFactor * alphaFactor,
      withAlphaXl:
          initialAlpha * alphaFactor * alphaFactor * alphaFactor * alphaFactor,
      withAlphaXXl: initialAlpha *
          alphaFactor *
          alphaFactor *
          alphaFactor *
          alphaFactor *
          alphaFactor,
      animationDurationShort:
          Duration(milliseconds: initialAnimationDuration.toInt()),
      animationDuration: Duration(
        milliseconds:
            (initialAnimationDuration * animationDurationFactor).toInt(),
      ),
      animationDurationLong: Duration(
        milliseconds: (initialAnimationDuration *
                animationDurationFactor *
                animationDurationFactor)
            .toInt(),
      ),
    );
  }

  factory ModelDsExtendedTokens.fromJson(Map<String, dynamic> json) {
    return ModelDsExtendedTokens(
      spacingXs: Utils.getDouble(json[ModelDsExtendedTokensKeys.spacingXs]),
      spacingSm: Utils.getDouble(json[ModelDsExtendedTokensKeys.spacingSm]),
      spacing: Utils.getDouble(json[ModelDsExtendedTokensKeys.spacing]),
      spacingLg: Utils.getDouble(json[ModelDsExtendedTokensKeys.spacingLg]),
      spacingXl: Utils.getDouble(json[ModelDsExtendedTokensKeys.spacingXl]),
      spacingXXl: Utils.getDouble(json[ModelDsExtendedTokensKeys.spacingXXl]),
      borderRadiusXs:
          Utils.getDouble(json[ModelDsExtendedTokensKeys.borderRadiusXs]),
      borderRadiusSm:
          Utils.getDouble(json[ModelDsExtendedTokensKeys.borderRadiusSm]),
      borderRadius:
          Utils.getDouble(json[ModelDsExtendedTokensKeys.borderRadius]),
      borderRadiusLg:
          Utils.getDouble(json[ModelDsExtendedTokensKeys.borderRadiusLg]),
      borderRadiusXl:
          Utils.getDouble(json[ModelDsExtendedTokensKeys.borderRadiusXl]),
      borderRadiusXXl:
          Utils.getDouble(json[ModelDsExtendedTokensKeys.borderRadiusXXl]),
      elevationXs: Utils.getDouble(json[ModelDsExtendedTokensKeys.elevationXs]),
      elevationSm: Utils.getDouble(json[ModelDsExtendedTokensKeys.elevationSm]),
      elevation: Utils.getDouble(json[ModelDsExtendedTokensKeys.elevation]),
      elevationLg: Utils.getDouble(json[ModelDsExtendedTokensKeys.elevationLg]),
      elevationXl: Utils.getDouble(json[ModelDsExtendedTokensKeys.elevationXl]),
      elevationXXl:
          Utils.getDouble(json[ModelDsExtendedTokensKeys.elevationXXl]),
      withAlphaXs: Utils.getDouble(json[ModelDsExtendedTokensKeys.withAlphaXs]),
      withAlphaSm: Utils.getDouble(json[ModelDsExtendedTokensKeys.withAlphaSm]),
      withAlpha: Utils.getDouble(json[ModelDsExtendedTokensKeys.withAlpha]),
      withAlphaLg: Utils.getDouble(json[ModelDsExtendedTokensKeys.withAlphaLg]),
      withAlphaXl: Utils.getDouble(json[ModelDsExtendedTokensKeys.withAlphaXl]),
      withAlphaXXl:
          Utils.getDouble(json[ModelDsExtendedTokensKeys.withAlphaXXl]),
      animationDurationShort: Duration(
        milliseconds: Utils.getIntegerFromDynamic(
          json[ModelDsExtendedTokensKeys.animationDurationShort],
        ),
      ),
      animationDuration: Duration(
        milliseconds: Utils.getIntegerFromDynamic(
          json[ModelDsExtendedTokensKeys.animationDuration],
        ),
      ),
      animationDurationLong: Duration(
        milliseconds: Utils.getIntegerFromDynamic(
          json[ModelDsExtendedTokensKeys.animationDurationLong],
        ),
      ),
    );
  }

  final double spacingXs;
  final double spacingSm;
  final double spacing;
  final double spacingLg;
  final double spacingXl;
  final double spacingXXl;

  final double borderRadiusXs;
  final double borderRadiusSm;
  final double borderRadius;
  final double borderRadiusLg;
  final double borderRadiusXl;
  final double borderRadiusXXl;

  final double elevationXs;
  final double elevationSm;
  final double elevation;
  final double elevationLg;
  final double elevationXl;
  final double elevationXXl;

  // Como DS en flutter no soporta ya opacity se expresa como inverso del alpha
  final double withAlphaXs;
  final double withAlphaSm;
  final double withAlpha;
  final double withAlphaLg;
  final double withAlphaXl;
  final double withAlphaXXl;

  final Duration animationDurationShort;
  final Duration animationDuration;
  final Duration animationDurationLong;

  ModelDsExtendedTokens copyWith({
    double? spacingXs,
    double? spacingSm,
    double? spacing,
    double? spacingLg,
    double? spacingXl,
    double? spacingXXl,
    double? borderRadiusXs,
    double? borderRadiusSm,
    double? borderRadius,
    double? borderRadiusLg,
    double? borderRadiusXl,
    double? borderRadiusXXl,
    double? elevationXs,
    double? elevationSm,
    double? elevation,
    double? elevationLg,
    double? elevationXl,
    double? elevationXXl,
    double? withAlphaXs,
    double? withAlphaSm,
    double? withAlpha,
    double? withAlphaLg,
    double? withAlphaXl,
    double? withAlphaXXl,
    Duration? animationDurationShort,
    Duration? animationDuration,
    Duration? animationDurationLong,
  }) {
    return ModelDsExtendedTokens(
      spacingXs: spacingXs ?? this.spacingXs,
      spacingSm: spacingSm ?? this.spacingSm,
      spacing: spacing ?? this.spacing,
      spacingLg: spacingLg ?? this.spacingLg,
      spacingXl: spacingXl ?? this.spacingXl,
      spacingXXl: spacingXXl ?? this.spacingXXl,
      borderRadiusXs: borderRadiusXs ?? this.borderRadiusXs,
      borderRadiusSm: borderRadiusSm ?? this.borderRadiusSm,
      borderRadius: borderRadius ?? this.borderRadius,
      borderRadiusLg: borderRadiusLg ?? this.borderRadiusLg,
      borderRadiusXl: borderRadiusXl ?? this.borderRadiusXl,
      borderRadiusXXl: borderRadiusXXl ?? this.borderRadiusXXl,
      elevationXs: elevationXs ?? this.elevationXs,
      elevationSm: elevationSm ?? this.elevationSm,
      elevation: elevation ?? this.elevation,
      elevationLg: elevationLg ?? this.elevationLg,
      elevationXl: elevationXl ?? this.elevationXl,
      elevationXXl: elevationXXl ?? this.elevationXXl,
      withAlphaXs: withAlphaXs ?? this.withAlphaXs,
      withAlphaSm: withAlphaSm ?? this.withAlphaSm,
      withAlpha: withAlpha ?? this.withAlpha,
      withAlphaLg: withAlphaLg ?? this.withAlphaLg,
      withAlphaXl: withAlphaXl ?? this.withAlphaXl,
      withAlphaXXl: withAlphaXXl ?? this.withAlphaXXl,
      animationDurationShort:
          animationDurationShort ?? this.animationDurationShort,
      animationDuration: animationDuration ?? this.animationDuration,
      animationDurationLong:
          animationDurationLong ?? this.animationDurationLong,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ModelDsExtendedTokensKeys.spacingXs: spacingXs,
      ModelDsExtendedTokensKeys.spacingSm: spacingSm,
      ModelDsExtendedTokensKeys.spacing: spacing,
      ModelDsExtendedTokensKeys.spacingLg: spacingLg,
      ModelDsExtendedTokensKeys.spacingXl: spacingXl,
      ModelDsExtendedTokensKeys.spacingXXl: spacingXXl,
      ModelDsExtendedTokensKeys.borderRadiusXs: borderRadiusXs,
      ModelDsExtendedTokensKeys.borderRadiusSm: borderRadiusSm,
      ModelDsExtendedTokensKeys.borderRadius: borderRadius,
      ModelDsExtendedTokensKeys.borderRadiusLg: borderRadiusLg,
      ModelDsExtendedTokensKeys.borderRadiusXl: borderRadiusXl,
      ModelDsExtendedTokensKeys.borderRadiusXXl: borderRadiusXXl,
      ModelDsExtendedTokensKeys.elevationXs: elevationXs,
      ModelDsExtendedTokensKeys.elevationSm: elevationSm,
      ModelDsExtendedTokensKeys.elevation: elevation,
      ModelDsExtendedTokensKeys.elevationLg: elevationLg,
      ModelDsExtendedTokensKeys.elevationXl: elevationXl,
      ModelDsExtendedTokensKeys.elevationXXl: elevationXXl,
      ModelDsExtendedTokensKeys.withAlphaXs: withAlphaXs,
      ModelDsExtendedTokensKeys.withAlphaSm: withAlphaSm,
      ModelDsExtendedTokensKeys.withAlpha: withAlpha,
      ModelDsExtendedTokensKeys.withAlphaLg: withAlphaLg,
      ModelDsExtendedTokensKeys.withAlphaXl: withAlphaXl,
      ModelDsExtendedTokensKeys.withAlphaXXl: withAlphaXXl,
      ModelDsExtendedTokensKeys.animationDurationShort:
          animationDurationShort.inMilliseconds,
      ModelDsExtendedTokensKeys.animationDuration:
          animationDuration.inMilliseconds,
      ModelDsExtendedTokensKeys.animationDurationLong:
          animationDurationLong.inMilliseconds,
    };
  }
}
