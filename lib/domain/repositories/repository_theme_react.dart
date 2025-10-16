part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

abstract class RepositoryThemeReact extends RepositoryTheme {
  Stream<Either<ErrorItem, ThemeState>> watch();
}
