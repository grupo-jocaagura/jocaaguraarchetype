part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// A loading indicator that can be supplied to a DS control.
abstract class DsLoading extends StatelessWidget {
  const DsLoading({super.key});
}

/// The default indeterminate indicator, using the DS size and progress theme.
class DsLoadingWidget extends DsLoading {
  const DsLoadingWidget({this.semanticLabel, super.key});

  /// Accessible label when the indicator is used on its own.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ModelDsExtendedTokens tokens = _itemTokensOf(context);
    return Center(
      widthFactor: 1,
      heightFactor: 1,
      child: SizedBox.square(
        dimension: tokens.spacingLg,
        child: CircularProgressIndicator(
          strokeWidth: tokens.spacingXs / 2,
          semanticsLabel: semanticLabel,
        ),
      ),
    );
  }
}
