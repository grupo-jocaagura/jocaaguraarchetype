part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Value object representing a queued toast/snackbar message.
///
/// The UI subscribes to a stream of [ToastMessage] and renders transient
/// notifications with optional severity and duration.
///
/// ### Example
/// ```dart
/// const ToastMessage(
///   text: 'Saved!',
///   level: ToastLevel.success,
///   duration: Duration(seconds: 2),
/// );
/// ```
@immutable
class ToastMessage {
  const ToastMessage(this.text, this.at);

  factory ToastMessage.empty() {
    return ToastMessage(
      '',
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  final String text;
  final DateTime at;

  bool get isEmpty => text.isEmpty;
  bool get isNotEmpty => text.isNotEmpty;

  ToastMessage copyWith({String? text, DateTime? at}) =>
      ToastMessage(text ?? this.text, at ?? this.at);

  @override
  int get hashCode => Object.hash(text, at.millisecondsSinceEpoch);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToastMessage &&
          other.text == text &&
          other.at.millisecondsSinceEpoch == at.millisecondsSinceEpoch;
}
