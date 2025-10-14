part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

abstract class GatewayThemeReact {
  Future<Either<ErrorItem, Map<String, dynamic>>> read();
  Future<Either<ErrorItem, Map<String, dynamic>>> write(
    Map<String, dynamic> json,
  );
  Stream<Either<ErrorItem, Map<String, dynamic>>> watch();
}
