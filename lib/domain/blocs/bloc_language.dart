part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Manages the application's active [ModelLanguage].
///
/// [BlocLanguage] keeps language selection independent from Flutter's
/// [Locale] representation and from application-level orchestration.
///
/// It owns:
///
/// - the languages supported by the application,
/// - the configured fallback language,
/// - the currently resolved language,
/// - deterministic language resolution through [LanguageResolutionPolicy].
///
/// Language preferences can be resolved using [resolvePreferredLanguages].
/// Explicit user selections can be applied using [selectLanguage].
///
/// [selectLanguage] only accepts exact supported languages. It does not apply
/// compatibility or fallback rules because an explicit selection represents
/// a concrete user intent.
///
/// Flutter-specific conversion between [ModelLanguage] and [Locale] remains
/// the responsibility of [LanguageLocaleMapper].
///
/// Example:
///
/// ```dart
/// void main() {
///   final BlocLanguage bloc = BlocLanguage(
///     supportedLanguages: const <ModelLanguage>[
///       ModelLanguage.spanishColombia,
///       ModelLanguage.englishUnitedStates,
///     ],
///     fallbackLanguage: ModelLanguage.spanishColombia,
///   );
///
///   bloc.selectLanguage(
///     ModelLanguage.englishUnitedStates,
///   );
///
///   assert(
///     bloc.language == ModelLanguage.englishUnitedStates,
///   );
///
///   bloc.dispose();
/// }
/// ```
class BlocLanguage extends BlocModule {
  /// Creates a language BLoC.
  ///
  /// [supportedLanguages] defines the languages that can be explicitly
  /// selected by the application or user.
  ///
  /// [fallbackLanguage] defines the preferred fallback when no preferred
  /// language can be resolved.
  ///
  /// [preferredLanguages] defines the initial ordered language preferences.
  /// They are resolved through [policy] during construction.
  ///
  /// [policy] controls deterministic language matching and fallback behavior.
  factory BlocLanguage({
    required Iterable<ModelLanguage> supportedLanguages,
    required ModelLanguage fallbackLanguage,
    Iterable<ModelLanguage> preferredLanguages = const <ModelLanguage>[],
    LanguageResolutionPolicy policy = const LanguageResolutionPolicy(),
  }) {
    final List<ModelLanguage> supported =
        List<ModelLanguage>.unmodifiable(supportedLanguages);

    final ModelLanguage initialLanguage = policy.resolve(
      preferredLanguages: preferredLanguages,
      supportedLanguages: supported,
      fallbackLanguage: fallbackLanguage,
    );

    return BlocLanguage._(
      supportedLanguages: supported,
      fallbackLanguage: fallbackLanguage,
      policy: policy,
      initialLanguage: initialLanguage,
    );
  }

  BlocLanguage._({
    required List<ModelLanguage> supportedLanguages,
    required this.fallbackLanguage,
    required LanguageResolutionPolicy policy,
    required ModelLanguage initialLanguage,
  })  : _supportedLanguages = supportedLanguages,
        _policy = policy,
        _language = BlocGeneral<ModelLanguage>(initialLanguage),
        super();

  /// Canonical registry name for this BLoC.
  static const String name = 'BlocLanguage';

  final List<ModelLanguage> _supportedLanguages;
  final LanguageResolutionPolicy _policy;
  final BlocGeneral<ModelLanguage> _language;

  /// Configured fallback language.
  ///
  /// The fallback does not need to be an exact member of
  /// [supportedLanguages]. The resolution policy may resolve it to a
  /// compatible supported language.
  final ModelLanguage fallbackLanguage;

  /// Immutable ordered list of languages supported by the application.
  List<ModelLanguage> get supportedLanguages => _supportedLanguages;

  /// Stream of active language snapshots.
  ///
  /// Consumers can subscribe to react whenever the active language changes.
  Stream<ModelLanguage> get stream => _language.stream;

  /// Current active language snapshot.
  ModelLanguage get language => _language.value;

  /// Returns whether [candidate] is exactly supported.
  ///
  /// This method does not perform language compatibility resolution.
  bool isSupported(ModelLanguage candidate) {
    return _supportedLanguages.contains(candidate);
  }

  /// Resolves [preferredLanguages] and makes the result the active language.
  ///
  /// Preferences are evaluated by [LanguageResolutionPolicy], including
  /// compatible language variants and fallback behavior.
  ///
  /// Returns the resolved active language.
  ModelLanguage resolvePreferredLanguages(
    Iterable<ModelLanguage> preferredLanguages,
  ) {
    final ModelLanguage resolved = _policy.resolve(
      preferredLanguages: preferredLanguages,
      supportedLanguages: _supportedLanguages,
      fallbackLanguage: fallbackLanguage,
    );

    _emit(resolved);
    return resolved;
  }

  /// Attempts to explicitly select [candidate].
  ///
  /// Explicit selection requires an exact match in [supportedLanguages].
  /// No language compatibility or fallback resolution is performed.
  ///
  /// Returns `true` when [candidate] is supported. Returns `false` and keeps
  /// the current language unchanged otherwise.
  bool selectLanguage(ModelLanguage candidate) {
    if (!isSupported(candidate)) {
      return false;
    }

    _emit(candidate);
    return true;
  }

  /// Restores the language resolved from [fallbackLanguage].
  ///
  /// The configured fallback is passed through [LanguageResolutionPolicy], so
  /// a compatible supported language can be selected when the exact fallback
  /// is unavailable.
  ///
  /// Returns the resulting active language.
  ModelLanguage reset() {
    final ModelLanguage resolved = _policy.resolve(
      preferredLanguages: const <ModelLanguage>[],
      supportedLanguages: _supportedLanguages,
      fallbackLanguage: fallbackLanguage,
    );

    _emit(resolved);
    return resolved;
  }

  void _emit(ModelLanguage next) {
    if (next == language) {
      return;
    }

    _language.value = next;
  }

  /// Releases the underlying reactive language state.
  @override
  void dispose() {
    _language.dispose();
  }
}
