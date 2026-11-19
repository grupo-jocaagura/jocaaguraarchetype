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
  external void preventDefault();
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
