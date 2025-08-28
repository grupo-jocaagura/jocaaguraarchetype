/// DO NOT MIX WITH UI SURFACE.
/// This sub-library re-exports the domain package for convenience.
/// Consumers must import this file explicitly to access domain APIs.
///
/// Rationale:
/// - Keep the archetype's public UI/navigation surface clean.
/// - Make domain exposure explicit and isolated, easing version compatibility.
///
/// Example:
/// ```dart
/// import 'package:jocaaguraarchetype/jocaaguraarchetype.dart';
///
/// // Now domain symbols are available here:
/// final BlocConnectivity bloc = BlocConnectivity();
/// ```
library jocaaguraarchetype_domain;

export 'package:jocaagura_domain/jocaagura_domain.dart';
