part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Renders the built-in Design System gallery controlled by [BlocGallery].
///
/// This page is navigation-agnostic. It does not use Flutter Navigator to move
/// between gallery pages; it only advances the internal [BlocGallery] index.
class DsGalleryPage extends StatefulWidget {
  const DsGalleryPage({this.designSystem, this.bloc, super.key});

  final ModelDesignSystem? designSystem;
  final BlocGallery? bloc;

  @override
  State<DsGalleryPage> createState() => _DsGalleryPageState();
}

class _DsGalleryPageState extends State<DsGalleryPage> {
  late BlocGallery _bloc;

  @override
  void initState() {
    super.initState();

    _bloc = widget.bloc ?? BlocGallery(designSystem: widget.designSystem);
  }

  @override
  void didUpdateWidget(covariant DsGalleryPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.bloc != widget.bloc) {
      if (oldWidget.bloc == null) {
        _bloc.dispose();
      }
      _bloc = widget.bloc ?? BlocGallery(designSystem: widget.designSystem);
    } else if (widget.bloc == null &&
        oldWidget.designSystem != widget.designSystem) {
      _bloc.setDesignSystem(widget.designSystem ?? defaultModelDesignSystem());
    }
  }

  @override
  void dispose() {
    if (widget.bloc == null) {
      _bloc.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ModelDsGalleryState>(
      key: ObjectKey(_bloc),
      stream: _bloc.stream,
      initialData: _bloc.state,
      builder:
          (BuildContext context, AsyncSnapshot<ModelDsGalleryState> snapshot) {
            final ModelDsGalleryState state = snapshot.data ?? _bloc.state;
            final ModelDsGalleryPageEntry? currentPage = state.currentPage;

            return Theme(
              data: state.designSystem.toThemeData(
                brightness: Theme.of(context).brightness,
              ),
              child: Scaffold(
                body: currentPage == null
                    ? const Center(child: Text('No gallery pages available.'))
                    : Builder(
                        builder: (BuildContext galleryContext) =>
                            currentPage.builder(galleryContext, _bloc, state),
                      ),
                bottomNavigationBar: DsGalleryNavigationControls(
                  state: state,
                  onPrevious: _bloc.previous,
                  onIndex: _bloc.goToIndex,
                  onNext: _bloc.next,
                ),
              ),
            );
          },
    );
  }
}
