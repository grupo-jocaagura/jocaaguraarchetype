part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

abstract class GatewayThemeReact extends GatewayTheme {
  Stream<Either<ErrorItem, Map<String, dynamic>>> watch();
}
