part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// {@template bloc_model_version}
/// Reactive BLoC that holds the current [ModelAppVersion] for the app.
///
/// This BLoC is intentionally minimal:
/// - It does NOT perform HTTP calls by itself.
/// - It simply stores the latest [ModelAppVersion] emitted by your use cases.
///
/// Typical usage:
///
/// ```dart
/// final BlocModelVersion blocModelVersion = BlocModelVersion();
///
/// // Listen from UI:
/// blocModelVersion.stream.listen((ModelAppVersion version) {
///   // React to version changes (e.g., show banner, force update screen, etc.).
/// });
///
/// // Update from a use case:
/// Future<void> refreshVersion() async {
///   final Either<ErrorItem, ModelAppVersion> result = await usecaseGetAppVersion();
///
///   result.fold(
///     (ErrorItem error) {
///       // Handle error (logging, telemetry, etc.).
///     },
///     (ModelAppVersion version) {
///       blocModelVersion.setVersion(version);
///     },
///   );
/// }
/// ```
///
/// The initial state uses [ModelAppVersion.defaultModelAppVersion], so existing
/// apps remain compatible even if no remote version check is configured.
/// {@endtemplate}
class BlocModelVersion extends BlocModule {
  /// Creates a [BlocModelVersion] with the given [initial] value.
  ///
  /// If you don't provide an [initial] value, it will use
  /// [ModelAppVersion.defaultModelAppVersion] to guarantee a valid snapshot
  /// for legacy or offline scenarios.
  BlocModelVersion({
    ModelAppVersion initial = ModelAppVersion.defaultModelAppVersion,
  })  : _bloc = BlocGeneral<ModelAppVersion>(initial),
        super();

  /// Canonical name for registry-based access in [AppManager] or similar maps.
  static const String name = 'BlocModelVersion';

  /// Internal reactive bloc that manages the current [ModelAppVersion].
  final BlocGeneral<ModelAppVersion> _bloc;

  /// Stream of [ModelAppVersion] updates.
  ///
  /// UI widgets or other modules can subscribe to this stream to react whenever
  /// the app version descriptor changes.
  Stream<ModelAppVersion> get stream => _bloc.stream;

  /// Current snapshot of the app version.
  ///
  /// This always holds some value; by default, it is
  /// [ModelAppVersion.defaultModelAppVersion] unless updated by your logic.
  ModelAppVersion get value => _bloc.value;

  /// Replaces the current snapshot with [version] and notifies all listeners.
  ///
  /// This is the primary entry point for use cases that resolve the version
  /// from network, local cache, or any other source.
  void setVersion(ModelAppVersion version) {
    if (version != _bloc.value) {
      _bloc.value = version;
    }
  }

  /// Resets the version to [ModelAppVersion.defaultModelAppVersion].
  ///
  /// Useful in testing scenarios or when you want to clear app-specific
  /// overrides (for example, on logout or environment switch).
  void resetToDefault() {
    _bloc.value = ModelAppVersion.defaultModelAppVersion;
  }

  /// Disposes the underlying [BlocGeneral] and frees stream resources.
  @override
  void dispose() {
    _bloc.dispose();
  }
}
