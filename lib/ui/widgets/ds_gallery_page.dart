part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Renders the built-in Design System gallery controlled by [BlocGallery].
///
/// This page is navigation-agnostic. It does not use Flutter Navigator to move
/// between gallery pages; it only advances the internal [BlocGallery] index.
class DsGalleryPage extends StatefulWidget {
  const DsGalleryPage({
    this.designSystem,
    this.bloc,
    super.key,
  });

  final ModelDesignSystem? designSystem;
  final BlocGallery? bloc;

  @override
  State<DsGalleryPage> createState() => _DsGalleryPageState();
}

class _DsGalleryPageState extends State<DsGalleryPage> {
  late final BlocGallery _bloc;
  late final bool _ownsBloc;

  @override
  void initState() {
    super.initState();

    _ownsBloc = widget.bloc == null;
    _bloc = widget.bloc ??
        BlocGallery(
          designSystem: widget.designSystem ?? defaultModelDesignSystem(),
        );
  }

  @override
  void didUpdateWidget(covariant DsGalleryPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.bloc == null &&
        widget.designSystem != null &&
        oldWidget.designSystem != widget.designSystem) {
      _bloc.setDesignSystem(widget.designSystem!);
    }
  }

  @override
  void dispose() {
    if (_ownsBloc) {
      _bloc.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ModelDsGalleryState>(
      stream: _bloc.stream,
      initialData: _bloc.state,
      builder: (
        BuildContext context,
        AsyncSnapshot<ModelDsGalleryState> snapshot,
      ) {
        final ModelDsGalleryState state = snapshot.data ?? _bloc.state;
        final ModelDsGalleryPageEntry? currentPage = state.currentPage;

        return Scaffold(
          body: currentPage == null
              ? const Center(
                  child: Text('No gallery pages available.'),
                )
              : currentPage.builder(
                  context,
                  _bloc,
                  state,
                ),
          bottomNavigationBar: DsGalleryNavigationControls(
            state: state,
            onPrevious: _bloc.previous,
            onIndex: _bloc.goToIndex,
            onNext: _bloc.next,
          ),
        );
      },
    );
  }
}
