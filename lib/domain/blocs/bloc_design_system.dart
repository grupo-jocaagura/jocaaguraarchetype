part of 'package:jocaaguraarchetype/jocaaguraarchetype.dart';

enum DsThemeTarget {
  light,
  dark,
  both,
}

class BlocDesignSystem extends BlocModule {
  BlocDesignSystem(this.ds)
      : _lastGoodDs = ds,
        _dsBloc = BlocGeneral<Either<ErrorItem, ModelDesignSystem>>(
          Right<ErrorItem, ModelDesignSystem>(ds),
        );

  final ModelDesignSystem ds;
  static const String name = 'BlocDesignSystem';

  final BlocGeneral<Either<ErrorItem, ModelDesignSystem>> _dsBloc;
  ModelDesignSystem _lastGoodDs;
  ModelDesignSystem get lastGoodDs => _lastGoodDs;
  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;

  ErrorItem? get currentErrorOrNull => _dsBloc.value.when(
        (ErrorItem e) => e,
        (ModelDesignSystem _) => null,
      );
  DsThemeTarget dsThemeTargetFromBrightness(Brightness? brightness) {
    if (brightness == null) {
      return DsThemeTarget.both;
    }
    return (brightness == Brightness.dark)
        ? DsThemeTarget.dark
        : DsThemeTarget.light;
  }

  ThemeData dsThemeFromBrightness(Brightness? brightness) {
    final ModelDesignSystem ds = requireDs();
    if (brightness == null) {
      // Por convención, devolvemos el light si es null
      return ds.toThemeData(brightness: Brightness.light);
    }
    return ds.toThemeData(brightness: brightness);
  }

  ThemeData dsThemeFromTarget(DsThemeTarget target) {
    final ModelDesignSystem ds = requireDs();
    switch (target) {
      case DsThemeTarget.light:
        return ds.toThemeData(brightness: Brightness.light);
      case DsThemeTarget.dark:
        return ds.toThemeData(brightness: Brightness.dark);
      case DsThemeTarget.both:
        // Por convención, devolvemos el light si es "both"
        return ds.toThemeData(brightness: Brightness.light);
    }
  }

  void ensureNotDisposed() {
    if (_isDisposed) {
      throw StateError(
        'BlocDesignSystem has been disposed and can no longer be used.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Streams y accesos
  // ---------------------------------------------------------------------------

  Stream<Either<ErrorItem, ModelDesignSystem>> get dsStream => _dsBloc.stream;

  Either<ErrorItem, ModelDesignSystem> get currentEither => _dsBloc.value;

  ModelDesignSystem? get currentDsOrNull {
    return _dsBloc.value.when(
      (ErrorItem _) => null,
      (ModelDesignSystem ds) => ds,
    );
  }

  /// Para casos donde *debes* tener DS (por ejemplo, en tests o boot).
  /// Lanza StateError si el bloc está en Left.
  ModelDesignSystem requireDs() {
    ensureNotDisposed();
    return _dsBloc.value.when(
      (ErrorItem _) => _lastGoodDs,
      (ModelDesignSystem v) => v,
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers de errores
  // ---------------------------------------------------------------------------

  static ErrorItem _error(
    String code,
    String title,
    String description, {
    ErrorLevelEnum level = ErrorLevelEnum.severe,
    Map<String, dynamic> meta = const <String, dynamic>{},
  }) {
    return ErrorItem(
      title: title,
      code: code,
      description: description,
      errorLevel: level,
      meta: meta,
    );
  }

  static ErrorItem _errorFromException(
    Object e,
    StackTrace st, {
    String code = 'DS_UPDATE_FAILED',
    String title = 'Design System update failed',
    ErrorLevelEnum level = ErrorLevelEnum.severe,
  }) {
    return _error(
      code,
      title,
      e.toString(),
      level: level,
      meta: <String, dynamic>{
        'exceptionType': e.runtimeType.toString(),
        // Evita log gigante: deja solo un pedazo razonable
        'stack': st.toString().split('\n').take(12).join('\n'),
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Escrituras base (set / import / export)
  // ---------------------------------------------------------------------------

  void setNewDs(ModelDesignSystem newDs) {
    ensureNotDisposed();
    final Either<ErrorItem, ModelDesignSystem> next =
        Right<ErrorItem, ModelDesignSystem>(newDs);
    if (next == _dsBloc.value) {
      return;
    }
    _dsBloc.value = next;
  }

  void importFromJson(Map<String, dynamic> json) {
    tryUpdate((ModelDesignSystem _) => ModelDesignSystem.fromJson(json));
  }

  Map<String, dynamic> exportToJson() {
    ensureNotDisposed();
    final ModelDesignSystem ds = requireDs();
    return ds.toJson();
  }

  // ---------------------------------------------------------------------------
  // Update seguro (sin errores volando)
  // ---------------------------------------------------------------------------

  /// Actualiza el DS si actualmente estamos en Right.
  ///
  /// Si el bloc está en Left, no intenta mutar (evita “editar sobre error”).
  /// Si hay excepción, pasa a Left con ErrorItem.
  void tryUpdate(
    ModelDesignSystem Function(ModelDesignSystem current) builder,
  ) {
    ensureNotDisposed();

    _dsBloc.value = _dsBloc.value.when(
      (ErrorItem e) => Left<ErrorItem, ModelDesignSystem>(e),
      (ModelDesignSystem current) {
        try {
          final ModelDesignSystem next = builder(current);
          if (next != current) {
            _lastGoodDs = next; // <-- clave
          }
          return Right<ErrorItem, ModelDesignSystem>(next);
        } catch (e, st) {
          return Left<ErrorItem, ModelDesignSystem>(
            _errorFromException(e, st),
          );
        }
      },
    );
  }

  /// Igual a tryUpdate pero permite que si estamos en Left,
  /// podamos “recuperar” forzando un DS base.
  void tryRecover({
    required ModelDesignSystem fallback,
    required ModelDesignSystem Function(ModelDesignSystem current) builder,
  }) {
    ensureNotDisposed();
    _dsBloc.value = _dsBloc.value.when(
      (ErrorItem _) {
        try {
          final ModelDesignSystem next = builder(fallback);
          return Right<ErrorItem, ModelDesignSystem>(next);
        } catch (e, st) {
          return Left<ErrorItem, ModelDesignSystem>(
            _errorFromException(e, st, code: 'DS_RECOVER_FAILED'),
          );
        }
      },
      (ModelDesignSystem current) {
        try {
          final ModelDesignSystem next = builder(current);
          return Right<ErrorItem, ModelDesignSystem>(next);
        } catch (e, st) {
          return Left<ErrorItem, ModelDesignSystem>(
            _errorFromException(e, st),
          );
        }
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Operaciones por sección (usan tryUpdate)
  // ---------------------------------------------------------------------------

  void setTheme(ModelThemeData theme) {
    tryUpdate((ModelDesignSystem c) => c.copyWith(theme: theme));
  }

  void setTokens(ModelDsExtendedTokens tokens) {
    tryUpdate((ModelDesignSystem c) => c.copyWith(tokens: tokens));
  }

  void setSemanticLight(ModelSemanticColors semantic) {
    tryUpdate((ModelDesignSystem c) => c.copyWith(semanticLight: semantic));
  }

  void setSemanticDark(ModelSemanticColors semantic) {
    tryUpdate((ModelDesignSystem c) => c.copyWith(semanticDark: semantic));
  }

  void setDataViz(ModelDataVizPalette palette) {
    tryUpdate((ModelDesignSystem c) => c.copyWith(dataViz: palette));
  }

  ModelSemanticColors semanticFor(Brightness brightness) {
    final ModelDesignSystem c = requireDs();
    return brightness == Brightness.dark ? c.semanticDark : c.semanticLight;
  }

  void resetSemanticToFallback() {
    tryUpdate(
      (ModelDesignSystem c) => c.copyWith(
        semanticLight: ModelSemanticColors.fallbackLight(),
        semanticDark: ModelSemanticColors.fallbackDark(),
      ),
    );
  }

  void deriveSemanticFromCurrentTheme() {
    tryUpdate((ModelDesignSystem c) {
      final ColorScheme lightCs =
          c.theme.toThemeData(brightness: Brightness.light).colorScheme;
      final ColorScheme darkCs =
          c.theme.toThemeData(brightness: Brightness.dark).colorScheme;

      return c.copyWith(
        semanticLight: ModelSemanticColors.fromColorScheme(lightCs),
        semanticDark: ModelSemanticColors.fromColorScheme(darkCs),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Parches granulares (tokens / dataviz / semantic)
  // ---------------------------------------------------------------------------

  void patchTokens({
    double? spacingXs,
    double? spacingSm,
    double? spacing,
    double? spacingLg,
    double? spacingXl,
    double? spacingXXl,
    double? borderRadiusXs,
    double? borderRadiusSm,
    double? borderRadius,
    double? borderRadiusLg,
    double? borderRadiusXl,
    double? borderRadiusXXl,
    double? elevationXs,
    double? elevationSm,
    double? elevation,
    double? elevationLg,
    double? elevationXl,
    double? elevationXXl,
    double? withAlphaXs,
    double? withAlphaSm,
    double? withAlpha,
    double? withAlphaLg,
    double? withAlphaXl,
    double? withAlphaXXl,
    Duration? animationDurationShort,
    Duration? animationDuration,
    Duration? animationDurationLong,
  }) {
    tryUpdate((ModelDesignSystem c) {
      final ModelDsExtendedTokens next = c.tokens.copyWith(
        spacingXs: spacingXs,
        spacingSm: spacingSm,
        spacing: spacing,
        spacingLg: spacingLg,
        spacingXl: spacingXl,
        spacingXXl: spacingXXl,
        borderRadiusXs: borderRadiusXs,
        borderRadiusSm: borderRadiusSm,
        borderRadius: borderRadius,
        borderRadiusLg: borderRadiusLg,
        borderRadiusXl: borderRadiusXl,
        borderRadiusXXl: borderRadiusXXl,
        elevationXs: elevationXs,
        elevationSm: elevationSm,
        elevation: elevation,
        elevationLg: elevationLg,
        elevationXl: elevationXl,
        elevationXXl: elevationXXl,
        withAlphaXs: withAlphaXs,
        withAlphaSm: withAlphaSm,
        withAlpha: withAlpha,
        withAlphaLg: withAlphaLg,
        withAlphaXl: withAlphaXl,
        withAlphaXXl: withAlphaXXl,
        animationDurationShort: animationDurationShort,
        animationDuration: animationDuration,
        animationDurationLong: animationDurationLong,
      );
      return c.copyWith(tokens: next);
    });
  }

  void patchDataViz({
    List<Color>? categorical,
    List<Color>? sequential,
  }) {
    tryUpdate((ModelDesignSystem c) {
      final ModelDataVizPalette next = ModelDataVizPalette(
        categorical: categorical ?? c.dataViz.categorical,
        sequential: sequential ?? c.dataViz.sequential,
      );
      return c.copyWith(dataViz: next);
    });
  }

  void patchSemanticFor({
    required Brightness brightness,
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? onInfoContainer,
  }) {
    tryUpdate((ModelDesignSystem c) {
      final ModelSemanticColors base =
          (brightness == Brightness.dark) ? c.semanticDark : c.semanticLight;

      final ModelSemanticColors next = base.copyWith(
        success: success,
        onSuccess: onSuccess,
        successContainer: successContainer,
        onSuccessContainer: onSuccessContainer,
        warning: warning,
        onWarning: onWarning,
        warningContainer: warningContainer,
        onWarningContainer: onWarningContainer,
        info: info,
        onInfo: onInfo,
        infoContainer: infoContainer,
        onInfoContainer: onInfoContainer,
      );

      return (brightness == Brightness.dark)
          ? c.copyWith(semanticDark: next)
          : c.copyWith(semanticLight: next);
    });
  }

  void patchSemanticPairFor({
    required Brightness brightness,
    required String pairKey,
    required Color background,
    Color? onColor,
    bool autoOn = true,
  }) {
    final Color effectiveOn =
        onColor ?? (autoOn ? _pickOnColor(background) : Colors.white);

    switch (pairKey) {
      case ModelSemanticColorsKeys.success:
        patchSemanticFor(
          brightness: brightness,
          success: background,
          onSuccess: effectiveOn,
        );
        return;
      case ModelSemanticColorsKeys.successContainer:
        patchSemanticFor(
          brightness: brightness,
          successContainer: background,
          onSuccessContainer: effectiveOn,
        );
        return;
      case ModelSemanticColorsKeys.warning:
        patchSemanticFor(
          brightness: brightness,
          warning: background,
          onWarning: effectiveOn,
        );
        return;
      case ModelSemanticColorsKeys.warningContainer:
        patchSemanticFor(
          brightness: brightness,
          warningContainer: background,
          onWarningContainer: effectiveOn,
        );
        return;
      case ModelSemanticColorsKeys.info:
        patchSemanticFor(
          brightness: brightness,
          info: background,
          onInfo: effectiveOn,
        );
        return;
      case ModelSemanticColorsKeys.infoContainer:
        patchSemanticFor(
          brightness: brightness,
          infoContainer: background,
          onInfoContainer: effectiveOn,
        );
        return;
      default:
        // Esto se convierte a Left via tryUpdate? Aquí es sync, así que lo hacemos explícito:
        setError(
          _error(
            'DS_UNKNOWN_SEMANTIC_PAIR',
            'Unknown semantic pair key',
            'pairKey=$pairKey',
            meta: <String, dynamic>{'pairKey': pairKey},
          ),
        );
        return;
    }
  }

  // ---------------------------------------------------------------------------
  // Preview rápido
  // ---------------------------------------------------------------------------

  ThemeData? buildThemeDataLightOrNull() {
    final ModelDesignSystem? c = currentDsOrNull;
    if (c == null) {
      return null;
    }
    return c.toThemeData(brightness: Brightness.light);
  }

  ThemeData? buildThemeDataDarkOrNull() {
    final ModelDesignSystem? c = currentDsOrNull;
    if (c == null) {
      return null;
    }
    return c.toThemeData(brightness: Brightness.dark);
  }

  // ---------------------------------------------------------------------------
  // Internos de contraste (determinísticos)
  // ---------------------------------------------------------------------------

  static double _contrastRatio(Color a, Color b) {
    final double l1 = a.computeLuminance();
    final double l2 = b.computeLuminance();
    final double hi = (l1 > l2) ? l1 : l2;
    final double lo = (l1 > l2) ? l2 : l1;
    return (hi + 0.05) / (lo + 0.05);
  }

  static Color _pickOnColor(Color background) {
    const Color white = Colors.white;
    const Color black = Colors.black;

    final double cWhite = _contrastRatio(background, white);
    final double cBlack = _contrastRatio(background, black);

    return (cWhite >= cBlack) ? white : black;
  }
  // ---------------------------------------------------------------------------
  // Hooks de listeners (wrappers seguros)
  // ---------------------------------------------------------------------------

  /// Listener de bajo nivel: recibe el Either completo.
  void addListener(
    String key,
    void Function(Either<ErrorItem, ModelDesignSystem> val) listener, [
    bool executeNow = false,
  ]) {
    ensureNotDisposed();
    _dsBloc.addFunctionToProcessTValueOnStream(key, listener, executeNow);
  }

  void removeListener(String key) {
    ensureNotDisposed();
    _dsBloc.deleteFunctionToProcessTValueOnStream(key);
  }

  bool hasListener(String key) {
    ensureNotDisposed();
    return _dsBloc.containsKeyFunction(key);
  }

  /// Fuerza re-emisión del valor actual (sin modificarlo).
  /// Útil cuando el UI necesita “re-render” aunque el DS no cambie.
  void emitCurrent() {
    ensureNotDisposed();
    final Either<ErrorItem, ModelDesignSystem> current = _dsBloc.value;
    _dsBloc.value = current;
  }

  /// Listener de alto nivel: solo se dispara cuando hay DS (Right).
  /// Opcional, pero MUY útil para UI.
  void addDsListener(
    String key,
    void Function(ModelDesignSystem ds) onDs, [
    bool executeNow = false,
  ]) {
    ensureNotDisposed();

    void wrapper(Either<ErrorItem, ModelDesignSystem> either) {
      either.when((ErrorItem error) {}, (ModelDesignSystem ds) => onDs(ds));
    }

    _dsBloc.addFunctionToProcessTValueOnStream(key, wrapper, false);

    if (executeNow) {
      _dsBloc.value.when((ErrorItem _) {}, (ModelDesignSystem ds) => onDs(ds));
    }
  }

  /// Listener de alto nivel: solo errores (Left).
  void addErrorListener(
    String key,
    void Function(ErrorItem error) onError, [
    bool executeNow = false,
  ]) {
    ensureNotDisposed();

    void wrapper(Either<ErrorItem, ModelDesignSystem> either) {
      either.when((ErrorItem e) => onError(e), (ModelDesignSystem _) {});
    }

    _dsBloc.addFunctionToProcessTValueOnStream(key, wrapper, false);

    if (executeNow) {
      _dsBloc.value.when((ErrorItem e) => onError(e), (ModelDesignSystem _) {});
    }
  }

  // ---------------------------------------------------------------------------
  // Escrituras base (ejemplo)
  // ---------------------------------------------------------------------------

  void setError(ErrorItem error) {
    ensureNotDisposed();
    final Either<ErrorItem, ModelDesignSystem> next =
        Left<ErrorItem, ModelDesignSystem>(error);
    if (next == _dsBloc.value) {
      return;
    }
    _dsBloc.value = next;
  }

  void patchTheme(
    ModelThemeData Function(ModelThemeData current) builder,
  ) {
    tryUpdate((ModelDesignSystem c) {
      final ModelThemeData next = builder(c.theme);
      if (next == c.theme) {
        return c;
      }
      return c.copyWith(theme: next);
    });
  }

  void patchThemeScheme({
    required DsThemeTarget target,
    required ColorScheme Function(ColorScheme current) builder,
  }) {
    patchTheme((ModelThemeData t) {
      switch (target) {
        case DsThemeTarget.light:
          return t.copyWith(lightScheme: builder(t.lightScheme));
        case DsThemeTarget.dark:
          return t.copyWith(darkScheme: builder(t.darkScheme));
        case DsThemeTarget.both:
          return t.copyWith(
            lightScheme: builder(t.lightScheme),
            darkScheme: builder(t.darkScheme),
          );
      }
    });
  }

  void patchThemeTextTheme({
    required DsThemeTarget target,
    required TextTheme Function(TextTheme current) builder,
  }) {
    patchTheme((ModelThemeData t) {
      switch (target) {
        case DsThemeTarget.light:
          return t.copyWith(lightTextTheme: builder(t.lightTextTheme));
        case DsThemeTarget.dark:
          return t.copyWith(darkTextTheme: builder(t.darkTextTheme));
        case DsThemeTarget.both:
          return t.copyWith(
            lightTextTheme: builder(t.lightTextTheme),
            darkTextTheme: builder(t.darkTextTheme),
          );
      }
    });
  }

  void setUseMaterial3(bool value) {
    patchTheme((ModelThemeData t) => t.copyWith(useMaterial3: value));
  }

  @override
  void dispose() {
    if (!_isDisposed) {
      _isDisposed = true;
      _dsBloc.dispose();
    }
  }
}
