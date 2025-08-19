part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

abstract class RepositoryTheme {
  Future<Either<ErrorItem, ThemeState>> read();
  Future<Either<ErrorItem, ThemeState>> save(ThemeState next);
}
