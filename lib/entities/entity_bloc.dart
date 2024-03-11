import 'dart:async';

/// [RepeatLastValueExtension] Retorna un nuevo Stream que repite el último valor emitido por este Stream.
///
/// [lastValue] es el último valor emitido por este Stream, que se repetirá en el nuevo Stream.
/// Si este Stream no emitió ningún valor, el [lastValue] será el primer valor emitido por el nuevo Stream.
///
/// Si [onCancel] es llamado en el nuevo Stream, se quitará el controlador de este Stream de la lista de controladores actuales.
///
/// Si [onError] es llamado en este Stream, el error será propagado al nuevo Stream y se cerrará el controlador del nuevo Stream.
///
/// Si [onDone] es llamado en este Stream, el nuevo Stream cerrará su controlador y no emitirá más eventos.
/// Creates a new instance of the `Stream` that repeats the `lastValue` parameter
/// whenever a new subscription is made.
extension RepeatLastValueExtension<T> on Stream<T> {
  Stream<T> call(T lastValue) {
    bool done = false;
    final Set<MultiStreamController<T>> currentListeners =
        <MultiStreamController<T>>{};
    listen(
      (T event) {
        for (final MultiStreamController<T> listener
            in <MultiStreamController<T>>[...currentListeners]) {
          listener.addSync(event);
        }
      },
      onError: (Object error, StackTrace stack) {
        for (final MultiStreamController<T> listener
            in <MultiStreamController<T>>[...currentListeners]) {
          listener.addErrorSync(error, stack);
        }
      },
      onDone: () {
        done = true;
        for (final MultiStreamController<T> listener in currentListeners) {
          listener.closeSync();
        }
        currentListeners.clear();
      },
    );
    return Stream<T>.multi((final MultiStreamController<T> controller) {
      if (done) {
        controller.close();
        return;
      }
      currentListeners.add(controller);
      controller.add(lastValue);
      controller.onCancel = () {
        currentListeners.remove(controller);
      };
    });
  }
}

abstract class EntityBloc {
  void dispose();
}

/// [Bloc] A generic class that implements a reactive programming pattern using Streams.
abstract class Bloc<T> {
  /// [Bloc] Constructs a new `Bloc` instance with the given `initialValue`.
  ///
  /// Example usage:
  /// ```
  /// final myBloc = MyBloc('initial value');
  /// ```
  Bloc(T initialValue) {
    _value = initialValue;
  }

  late T _value;

  /// [getValue] Returns the current value of the bloc.
  ///
  /// Example usage:
  /// ```
  /// final myBloc = MyBloc('initial value');
  /// print(myBloc.value); // 'initial value'
  /// ```
  T get value => _value;
  final StreamController<T> _streamController = StreamController<T>.broadcast();

  /// [stream] Returns the stream of the current bloc value.
  ///
  /// Example usage:
  /// ```
  /// final myBloc = MyBloc('initial value');
  /// myBloc.stream.listen((value) => print(value)); // 'initial value'
  /// ```
  Stream<T> get stream => _streamController.stream(value);

  /// [isClosed] access granted to check if the current _streamController is
  /// closed
  bool get isClosed => _streamController.isClosed;

  /// [value] Sets the current value of the bloc to `val` and notifies subscribers.
  ///
  /// Example usage:
  /// ```
  /// final myBloc = MyBloc('initial value');
  /// myBloc.value = 'new value'; // The stream will emit 'new value'
  /// ```
  set value(T val) {
    _streamController.sink.add(val);
    _value = val;
  }

  StreamSubscription<T>? _suscribe;

  /// [isSubscribeActive] Returns `true` if the stream subscription is currently active, `false` otherwise.
  ///
  /// Example usage:
  /// ```
  /// final myBloc = MyBloc('initial value');
  /// print(myBloc.isSubscribeActive); // false
  /// myBloc._setStreamSubsciption((value) => print(value));
  /// print(myBloc.isSubscribeActive); // true
  /// ```
  bool get isSubscribeActive => !(_suscribe == null);

  /// [_desuscribeStream] Cancels the current stream subscription.
  ///
  /// Example usage:
  /// ```
  /// final myBloc = MyBloc('initial value');
  /// myBloc._setStreamSubsciption((value) => print(value));
  /// myBloc._desuscribeStream(); // Subscription is cancelled
  /// ```
  void _desuscribeStream() {
    _suscribe?.cancel();
    _suscribe = null;
  }

  /// Sets a new subscription to the stream of events.
  /// [_setStreamSubscription] Sets a new stream subscription with the given `function`.
  ///
  /// Example usage:
  /// ```
  /// final myBloc = MyBloc('initial value');
  /// myBloc._setStreamSubsciption((value) => print(value));
  /// myBloc.value = 'new value'; // 'new value' is printed to console
  /// ```
  void _setStreamSubscription(void Function(T event) function) {
    _desuscribeStream();
    _suscribe = stream.listen((T event) {
      function(event);
    });
  }

  /// [dispose] Disposes of the `Bloc` by cancelling the subscription to the stream of events
  /// and closing the stream controller.
  /// Closes the stream and cancels the current stream subscription.
  ///
  /// Example usage:
  /// ```
  /// final myBloc = MyBloc('initial value');
  /// myBloc._setStreamSubsciption((value) => print(value));
  /// myBloc.dispose(); // Subscription is cancelled and stream is closed
  /// ```
  void dispose() {
    _desuscribeStream();
    _streamController.close();
  }
}

abstract class BlocModule {
  const BlocModule();
  void dispose();
}

class BlocGeneral<T> extends Bloc<T> {
  BlocGeneral(super.initialValue) {
    _setStreamSubscription((T event) {
      for (final void Function(T val) element in _functionsMap.values) {
        element(event);
      }
    });
  }

  final Map<String, void Function(T val)> _functionsMap =
      <String, void Function(T val)>{};

  void addFunctionToProcessTValueOnStream(
    String key,
    Function(T val) function, [
    bool executeNow = false,
  ]) {
    _functionsMap[key.toLowerCase()] = function;
    if (executeNow) {
      function(value);
    }
  }

  void deleteFunctionToProcessTValueOnStream(String key) {
    _functionsMap.remove(key);
  }

  T get valueOrNull => value;
  bool containsKeyFunction(String key) {
    return _functionsMap.containsKey(key);
  }

  void close() {
    dispose();
  }
}

/// The core class responsible for managing general and module BLoCs.
class BlocCore<T> {
  BlocCore([Map<String, BlocModule> map = const <String, BlocModule>{}]) {
    map.forEach((String key, BlocModule blocModule) {
      addBlocModule(key, blocModule);
    });
  }

  final Map<String, BlocGeneral<T>> _injector = <String, BlocGeneral<T>>{};
  final Map<String, BlocModule> _moduleInjector = <String, BlocModule>{};

  /// Returns a [BlocGeneral] instance for the given [key].
  ///
  /// Throws an [UnimplementedError] if the [BlocGeneral] for [key] has not been initialized.
  ///
  /// Example usage:
  /// ```
  /// final blocCore = BlocCore();
  /// final myBloc = MyBloc();
  /// blocCore.addBlocGeneral('myBloc', myBloc);
  ///
  /// final myBlocInstance = blocCore.getBloc<MyBloc>('myBloc');
  /// ```
  BlocGeneral<T> getBloc<T2>(String key) {
    final BlocGeneral<T>? tmp = _injector[key.toLowerCase()];

    if (tmp == null) {
      throw UnimplementedError('The BlocGeneral were not initialized');
    }

    return tmp;
  }

  /// [getBlocModule] Returns a [BlocModule] instance for the given [key].
  ///
  /// Throws an [UnimplementedError] if the [BlocModule] for [key] has not been initialized.
  ///
  /// Example usage:
  /// ```
  /// final blocCore = BlocCore();
  /// final myModule = MyModule();
  /// blocCore.addBlocModule('myModule', myModule);
  ///
  /// final myModuleInstance = blocCore.getBlocModule<MyModule>('myModule');
  /// ```
  V getBlocModule<V>(String key) {
    final BlocModule? tmp = _moduleInjector[key.toLowerCase()];
    if (tmp == null) {
      throw UnimplementedError('The BlocModule were not initialized');
    }
    return _moduleInjector[key.toLowerCase()] as V;
  }

  /// [addBlocGeneral] Adds a [BlocGeneral] instance to the injector with the given [key].
  ///
  /// Example usage:
  /// ```
  /// final blocCore = BlocCore();
  /// final myBloc = MyBloc();
  /// blocCore.addBlocGeneral('myBloc', myBloc);
  /// ```
  void addBlocGeneral(String key, BlocGeneral<T> blocGeneral) {
    _injector[key.toLowerCase()] = blocGeneral;
  }

  /// [isDisposed] Returns whether the injector and module injector are empty or not.
  ///
  /// Example usage:
  /// ```
  /// final blocCore = BlocCore();
  /// assert(blocCore.isDisposed == true);
  ///
  /// final myBloc = MyBloc();
  /// blocCore.addBlocGeneral('myBloc', myBloc);
  /// assert(blocCore.isDisposed == false);
  ///
  /// blocCore.dispose();
  /// assert(blocCore.isDisposed == true);
  /// ```
  bool get isDisposed => _injector.isEmpty && _moduleInjector.isEmpty;

  /// [addBlocModule] Adds a [BlocModule] instance to the module injector with the given [key].
  ///
  /// Example usage:
  /// ```
  /// final blocCore = BlocCore();
  /// final myModule = MyModule();
  /// blocCore.addBlocModule('myModule', myModule);
  /// ```
  void addBlocModule<BlocType>(String key, BlocModule blocModule) {
    _moduleInjector[key.toLowerCase()] = blocModule;
  }

  void deleteBlocGeneral(String key) {
    key = key.toLowerCase();
    _injector[key]?.dispose();
    _injector.remove(key);
  }

  void deleteBlocModule(String key) {
    key = key.toLowerCase();
    _moduleInjector[key]?.dispose();
    _moduleInjector.remove(key);
  }

  void dispose() {
    _injector.forEach(
      (String key, BlocGeneral<dynamic> value) {
        value.dispose();
      },
    );
    _moduleInjector.forEach(
      (String key, BlocModule value) {
        value.dispose();
      },
    );
    Future<void>.delayed(const Duration(milliseconds: 999), () {
      _injector.clear();
      _moduleInjector.clear();
    });
  }
}
