import 'dart:js_interop';

@JS('document')
external _ClipboardDocument get _clipboardDocument;

extension type _ClipboardDocument(JSObject _) implements JSObject {
  external void addEventListener(
    String type,
    JSFunction<void Function(_ClipboardEvent)> listener,
    bool capture,
  );
  external void removeEventListener(
    String type,
    JSFunction<void Function(_ClipboardEvent)> listener,
    bool capture,
  );
}

extension type _ClipboardEvent(JSObject _) implements JSObject {
  external _ClipboardData? get clipboardData;

  external void preventDefault();
}

extension type _ClipboardData(JSObject _) implements JSObject {
  external void setData(String type, String value);
}

void Function() blockPasswordClipboard(bool Function() isPasswordFocused) {
  final JSFunction<void Function(_ClipboardEvent)> block =
      ((_ClipboardEvent event) {
        if (isPasswordFocused()) {
          event.preventDefault();
        }
      }).toJS;
  final _ClipboardDocument document = _clipboardDocument;
  document.addEventListener('copy', block, true);
  document.addEventListener('cut', block, true);
  return () {
    document.removeEventListener('copy', block, true);
    document.removeEventListener('cut', block, true);
  };
}

void Function() listenToReadOnlyCopy(String? Function() selectedText) {
  final JSFunction<void Function(_ClipboardEvent)> copy =
      ((_ClipboardEvent event) {
        final String? text = selectedText();
        final _ClipboardData? clipboard = event.clipboardData;
        if (text != null && clipboard != null) {
          clipboard.setData('text/plain', text);
          event.preventDefault();
        }
      }).toJS;
  final _ClipboardDocument document = _clipboardDocument;
  document.addEventListener('copy', copy, true);
  return () => document.removeEventListener('copy', copy, true);
}
