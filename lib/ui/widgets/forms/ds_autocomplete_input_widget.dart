part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

/// Edit free-form text and choose from consumer-supplied suggestions.
///
/// Supply filtered options through [ModelFieldState.suggestions] in display
/// order. Publish a new list when results arrive, even if the text is unchanged.
/// Edits and explicit choices both propose a value through [onChangedAttempt].
/// [onSubmittedAttempt] handles submission when no suggestion is highlighted.
class DsAutocompleteInputWidget extends DsTextInputWidget {
  const DsAutocompleteInputWidget({
    required super.field,
    required super.onChangedAttempt,
    required super.label,
    super.onSubmittedAttempt,
    super.placeholder,
    super.helperText,
    super.required,
    super.enabled,
    super.readOnly,
    super.requiredSemanticLabel,
    super.readOnlySemanticLabel,
    super.key,
  });

  @override
  State<DsTextInputWidget> createState() => _DsAutocompleteInputWidgetState();
}

class _DsAutocompleteInputWidgetState extends _DsTextInputWidgetState {
  final OverlayPortalController _overlay = OverlayPortalController();
  final GlobalKey _highlightedLabelKey = GlobalKey();
  bool _editedWhileFocused = false;
  int? _highlightedIndex;

  List<String> get _suggestions => widget.field.suggestions;

  bool get _showSuggestions =>
      _canEdit &&
      _focusNode.hasFocus &&
      _editedWhileFocused &&
      _suggestions.isNotEmpty;

  bool get _isComposing =>
      _controller.value.isComposingRangeValid &&
      !_controller.value.composing.isCollapsed;

  bool get _canChooseWithKeyboard =>
      _showSuggestions && _highlightedIndex != null && !_isComposing;

  @override
  bool? get _suggestionsExpanded => _canEdit ? _showSuggestions : null;

  @override
  VoidCallback? get _onEditingComplete => _canChooseWithKeyboard
      ? () {
          // A keyboard choice keeps editing focus in the field.
        }
      : null;

  @override
  ValueChanged<String>? get _onTextSubmitted =>
      _canChooseWithKeyboard ? _submitWithSuggestions : super._onTextSubmitted;

  void _submitWithSuggestions(String text) {
    if (_canChooseWithKeyboard) {
      _choose(_suggestions[_highlightedIndex!]);
    } else if (!_isComposing) {
      _submitText(text);
    }
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant DsTextInputWidget oldWidget) {
    final bool replacedText =
        oldWidget.field.value != widget.field.value &&
        _controller.text != widget.field.value;
    super.didUpdateWidget(oldWidget);
    if (replacedText || !_canEdit) {
      _editedWhileFocused = false;
      _highlightedIndex = null;
    }
    final int? index = _highlightedIndex;
    if (index != null &&
        (index >= _suggestions.length ||
            _suggestions[index] != oldWidget.field.suggestions[index])) {
      _highlightedIndex = null;
    }
    if (_showSuggestions != _overlay.isShowing) {
      // Model updates can arrive during build, before the overlay can rebuild.
      WidgetsBinding.instance.addPostFrameCallback((Duration _) {
        if (mounted) {
          _syncOverlay();
        }
      });
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _editedWhileFocused) {
      _dismiss();
    }
  }

  @override
  void _onTextChanged(String raw) {
    setState(() {
      _editedWhileFocused = _focusNode.hasFocus && raw.isNotEmpty;
      _highlightedIndex = null;
    });
    _syncOverlay();
    super._onTextChanged(raw);
  }

  void _syncOverlay() {
    if (_showSuggestions && !_overlay.isShowing) {
      _overlay.show();
      unawaited(_announce(WidgetsLocalizations.of(context).searchResultsFound));
    } else if (!_showSuggestions && _overlay.isShowing) {
      _overlay.hide();
    }
  }

  void _dismiss() {
    setState(() {
      _editedWhileFocused = false;
      _highlightedIndex = null;
    });
    _syncOverlay();
  }

  void _choose(String suggestion) {
    if (!_showSuggestions || !_suggestions.contains(suggestion)) {
      return;
    }
    _dismiss();
    widget.onChangedAttempt(
      widget.field.copyWith(value: suggestion, isDirty: true),
    );
  }

  Future<void> _announce(String message) async {
    if (MediaQuery.supportsAnnounceOf(context)) {
      await SemanticsService.sendAnnouncement(
        View.of(context),
        message,
        Directionality.of(context),
      );
    }
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    final HardwareKeyboard keyboard = HardwareKeyboard.instance;
    if (!_showSuggestions ||
        _isComposing ||
        event is KeyUpEvent ||
        keyboard.isAltPressed ||
        keyboard.isControlPressed ||
        keyboard.isMetaPressed ||
        keyboard.isShiftPressed) {
      return KeyEventResult.ignored;
    }
    final LogicalKeyboardKey key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowUp) {
      final bool down = key == LogicalKeyboardKey.arrowDown;
      final int previous =
          _highlightedIndex ?? (down ? -1 : _suggestions.length);
      final int index = (previous + (down ? 1 : -1)).clamp(
        0,
        _suggestions.length - 1,
      );
      if (_highlightedIndex != index) {
        setState(() => _highlightedIndex = index);
        unawaited(_announce(_suggestions[index]));
        WidgetsBinding.instance.addPostFrameCallback((Duration _) {
          final BuildContext? labelContext =
              _highlightedLabelKey.currentContext;
          final RenderObject? label = labelContext?.findRenderObject();
          if (labelContext != null && label != null) {
            unawaited(
              Scrollable.of(labelContext).position
                  .ensureVisible(label, alignment: 0.5),
            );
          }
        });
      }
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      _dismiss();
      return KeyEventResult.handled;
    }
    if ((key == LogicalKeyboardKey.enter ||
            key == LogicalKeyboardKey.numpadEnter) &&
        _highlightedIndex != null) {
      _choose(_suggestions[_highlightedIndex!]);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Widget _buildSuggestions(
    BuildContext context,
    OverlayChildLayoutInfo layout,
  ) {
    if (!_showSuggestions || layout.childPaintTransform.determinant() == 0) {
      return const SizedBox.shrink();
    }
    final Rect screen = MediaQuery.paddingOf(context).deflateRect(
      MediaQuery.viewInsetsOf(context)
          .deflateRect(Offset.zero & layout.overlaySize),
    );
    final Rect available = MatrixUtils.transformRect(
      layout.childPaintTransform.clone()..invert(),
      screen,
    );
    final double below = available.bottom - layout.childSize.height;
    final double above = -available.top;
    final bool opensUp = above > below;
    final double height = min(240, max(above, below));
    if (height <= 0) {
      return const SizedBox.shrink();
    }
    final Matrix4 transform = layout.childPaintTransform.clone()
      ..translateByDouble(0, opensUp ? -height : layout.childSize.height, 0, 1);
    return Transform(
      transform: transform,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: layout.childSize.width,
          height: height,
          child: Align(
            alignment: opensUp ? Alignment.bottomLeft : Alignment.topLeft,
            child: TextFieldTapRegion(
              child: ExcludeFocus(child: _suggestionsList(context)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _suggestionsList(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ModelDsExtendedTokens tokens = _itemTokensOf(context);
    return Material(
      color: theme.colorScheme.surfaceContainer,
      elevation: 4,
      borderRadius: BorderRadius.circular(tokens.borderRadius),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        primary: false,
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          role: SemanticsRole.list,
          label: WidgetsLocalizations.of(context).searchResultsFound,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (final (int index, String suggestion) in _suggestions.indexed)
                _suggestion(context, suggestion, index == _highlightedIndex),
            ],
          ),
        ),
      ),
    );
  }

  Widget _suggestion(
    BuildContext context,
    String suggestion,
    bool highlighted,
  ) {
    final ThemeData theme = Theme.of(context);
    final ModelDsExtendedTokens tokens = _itemTokensOf(context);
    return Semantics(
      container: true,
      role: SemanticsRole.listItem,
      selected: highlighted,
      liveRegion: highlighted && !MediaQuery.supportsAnnounceOf(context),
      label: suggestion,
      onTap: () => _choose(suggestion),
      excludeSemantics: true,
      child: Ink(
        color: highlighted ? theme.colorScheme.secondaryContainer : null,
        child: InkWell(
          onTap: () => _choose(suggestion),
          child: Container(
            alignment: AlignmentDirectional.centerStart,
            constraints: const BoxConstraints(
              minHeight: kMinInteractiveDimension,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: tokens.spacing,
              vertical: tokens.spacingSm,
            ),
            child: Text(
              suggestion,
              key: highlighted ? _highlightedLabelKey : null,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: highlighted
                    ? theme.colorScheme.onSecondaryContainer
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _overlay,
      overlayChildBuilder: _buildSuggestions,
      child: Focus(
        canRequestFocus: false,
        includeSemantics: false,
        onKeyEvent: _handleKey,
        child: super.build(context),
      ),
    );
  }
}
