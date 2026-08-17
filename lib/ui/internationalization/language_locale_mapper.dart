part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Maps between the Jocaagura domain [ModelLanguage] and Flutter [Locale].
///
/// This mapper performs a deterministic structural conversion between the
/// domain representation of a language and Flutter's locale representation.
///
/// It does not resolve supported languages, choose fallbacks, or inspect the
/// platform locale. Those responsibilities belong to the language resolution
/// policy.
///
/// Empty optional domain subtags are represented as `null` in Flutter:
///
/// - `ModelLanguage.scriptCode == ''` becomes `Locale.scriptCode == null`.
/// - `ModelLanguage.regionCode == ''` becomes `Locale.countryCode == null`.
///
/// When mapping back to the domain, absent Flutter subtags are represented by
/// empty strings.
///
/// Example:
///
/// ```dart
/// const LanguageLocaleMapper mapper = LanguageLocaleMapper();
///
/// final Locale locale = mapper.toLocale(
///   ModelLanguage.spanishColombia,
/// );
///
/// final ModelLanguage language = mapper.fromLocale(locale);
///
/// void main() {
///   assert(locale.languageCode == 'es');
///   assert(locale.countryCode == 'CO');
///   assert(language == ModelLanguage.spanishColombia);
/// }
/// ```
class LanguageLocaleMapper {
  /// Creates a stateless language-locale mapper.
  const LanguageLocaleMapper();

  /// Converts [language] into its Flutter [Locale] representation.
  ///
  /// The language, script, and region subtags are transferred directly.
  /// Empty optional subtags are represented as `null`.
  Locale toLocale(ModelLanguage language) {
    return Locale.fromSubtags(
      languageCode: language.languageCode,
      scriptCode: language.scriptCode.isEmpty ? null : language.scriptCode,
      countryCode: language.regionCode.isEmpty ? null : language.regionCode,
    );
  }

  /// Converts [locale] into its domain [ModelLanguage] representation.
  ///
  /// Missing Flutter script and region subtags are represented by empty
  /// strings in the resulting domain model.
  ModelLanguage fromLocale(Locale locale) {
    return ModelLanguage(
      languageCode: locale.languageCode,
      scriptCode: locale.scriptCode ?? '',
      regionCode: locale.countryCode ?? '',
    );
  }
}
