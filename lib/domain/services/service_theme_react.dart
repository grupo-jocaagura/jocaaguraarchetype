part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

abstract class ServiceThemeReact {
  final BlocGeneral<Map<String, dynamic>> _themeStateJson =
      BlocGeneral<Map<String, dynamic>>(ThemeState.defaults.toJson());

  Stream<Map<String, dynamic>> get themeStream => _themeStateJson.stream;
  Map<String, dynamic> get themeStateJson => _themeStateJson.value;

  void updateTheme(Map<String, dynamic> json) {
    if (themeStateJson != json) {
      _themeStateJson.value = json;
    }
  }

  void addFunctionToProcessValueOnStream(
    String key,
    Function(Map<String, dynamic> val) function, [
    bool executeNow = false,
  ]) {
    _themeStateJson.addFunctionToProcessTValueOnStream(key, function);
  }

  void deleteFunctionToProcessValueOnStream(
    String key,
    Function(Map<String, dynamic> val) function, [
    bool executeNow = false,
  ]) {
    _themeStateJson.deleteFunctionToProcessTValueOnStream(key);
  }

  void dispose() {
    _themeStateJson.dispose();
  }
}
