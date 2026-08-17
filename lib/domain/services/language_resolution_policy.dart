part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Resolves the most appropriate supported [ModelLanguage].
///
/// Resolution is deterministic and preserves the order of the preferred
/// languages.
///
/// The policy prioritizes exact matches and progressively relaxes region and
/// script requirements while avoiding explicit script conflicts.
///
/// If no preferred language can be resolved, [fallbackLanguage] is attempted.
/// If the fallback cannot be resolved either, the first supported language is
/// returned.
///
/// When [supportedLanguages] is empty, [fallbackLanguage] is returned.
///
/// Example:
///
/// ```dart
/// const LanguageResolutionPolicy policy = LanguageResolutionPolicy();
///
/// final ModelLanguage language = policy.resolve(
///   preferredLanguages: <ModelLanguage>[
///     ModelLanguage.spanishMexico,
///   ],
///   supportedLanguages: <ModelLanguage>[
///     ModelLanguage.spanishColombia,
///     ModelLanguage.englishUnitedStates,
///   ],
///   fallbackLanguage: ModelLanguage.englishUnitedStates,
/// );
///
/// void main() {
///   assert(language == ModelLanguage.spanishColombia);
/// }
/// ```
class LanguageResolutionPolicy {
  /// Creates a stateless language resolution policy.
  const LanguageResolutionPolicy();

  /// Resolves the best language from [supportedLanguages].
  ///
  /// Preferred languages are evaluated in their provided order.
  ///
  /// When no preferred language matches, [fallbackLanguage] is resolved
  /// against the supported languages.
  ///
  /// If no supported language matches the fallback, the first supported
  /// language is returned.
  ///
  /// When [supportedLanguages] is empty, [fallbackLanguage] is returned.
  ModelLanguage resolve({
    required Iterable<ModelLanguage> preferredLanguages,
    required Iterable<ModelLanguage> supportedLanguages,
    required ModelLanguage fallbackLanguage,
  }) {
    final List<ModelLanguage> supported =
        supportedLanguages.toList(growable: false);

    if (supported.isEmpty) {
      return fallbackLanguage;
    }

    for (final ModelLanguage preferred in preferredLanguages) {
      final ModelLanguage? resolved = _resolveLanguage(
        preferred,
        supported,
      );

      if (resolved != null) {
        return resolved;
      }
    }

    return _resolveLanguage(
          fallbackLanguage,
          supported,
        ) ??
        supported.first;
  }

  ModelLanguage? _resolveLanguage(
    ModelLanguage preferred,
    List<ModelLanguage> supported,
  ) {
    // 1. Exact match.
    for (final ModelLanguage candidate in supported) {
      if (candidate == preferred) {
        return candidate;
      }
    }

    // 2. Language + script.
    if (preferred.scriptCode.isNotEmpty) {
      for (final ModelLanguage candidate in supported) {
        if (candidate.languageCode == preferred.languageCode &&
            candidate.scriptCode == preferred.scriptCode) {
          return candidate;
        }
      }
    }

    // 3. Language + region without an explicit script conflict.
    if (preferred.regionCode.isNotEmpty) {
      for (final ModelLanguage candidate in supported) {
        if (candidate.languageCode == preferred.languageCode &&
            candidate.regionCode == preferred.regionCode &&
            _scriptsAreCompatible(preferred, candidate)) {
          return candidate;
        }
      }
    }

    // 4. Generic language.
    for (final ModelLanguage candidate in supported) {
      if (candidate.languageCode == preferred.languageCode &&
          candidate.scriptCode.isEmpty &&
          candidate.regionCode.isEmpty) {
        return candidate;
      }
    }

    // 5. Compatible language variant.
    for (final ModelLanguage candidate in supported) {
      if (candidate.languageCode == preferred.languageCode &&
          _scriptsAreCompatible(preferred, candidate)) {
        return candidate;
      }
    }

    return null;
  }

  bool _scriptsAreCompatible(
    ModelLanguage preferred,
    ModelLanguage candidate,
  ) {
    return preferred.scriptCode.isEmpty ||
        candidate.scriptCode.isEmpty ||
        preferred.scriptCode == candidate.scriptCode;
  }
}
