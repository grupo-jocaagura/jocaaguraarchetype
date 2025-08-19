part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

abstract class GatewayTheme {
  Future<Either<ErrorItem, Map<String, dynamic>>> read();
  Future<Either<ErrorItem, Map<String, dynamic>>> write(
    Map<String, dynamic> json,
  );
}
