// utils/ui_throttle_mixin.dart

import 'dart:async';
import 'package:flutter/material.dart';

/// Mixin pour limiter la fréquence des mises à jour de l'UI
///
/// Utile pour les applications de santé avec collecte de données en continu
/// afin d'éviter les rafraîchissements brusques qui clignotent
mixin UIThrottleMixin<T extends StatefulWidget> on State<T> {
  Timer? _throttleTimer;
  bool _canUpdate = true;

  /// Durée minimale entre deux mises à jour de l'UI
  Duration get throttleDuration => const Duration(milliseconds: 500);

  /// Exécute une fonction de mise à jour seulement si le throttle le permet
  ///
  /// Usage:
  /// ```dart
  /// throttledUpdate(() {
  ///   setState(() {
  ///     // Vos mises à jour
  ///   });
  /// });
  /// ```
  void throttledUpdate(VoidCallback updateFunction) {
    if (_canUpdate) {
      updateFunction();
      _canUpdate = false;

      _throttleTimer?.cancel();
      _throttleTimer = Timer(throttleDuration, () {
        if (mounted) {
          _canUpdate = true;
        }
      });
    }
  }

  /// Exécute une fonction de mise à jour avec un debounce
  ///
  /// La fonction ne sera exécutée qu'après que [debounceDuration] se soit
  /// écoulé sans nouvel appel. Utile pour éviter trop d'appels successifs.
  ///
  /// Usage:
  /// ```dart
  /// debouncedUpdate(() {
  ///   setState(() {
  ///     // Vos mises à jour
  ///   });
  /// });
  /// ```
  void debouncedUpdate(
    VoidCallback updateFunction, {
    Duration? debounceDuration,
  }) {
    _throttleTimer?.cancel();
    _throttleTimer = Timer(
      debounceDuration ?? throttleDuration,
      () {
        if (mounted) {
          updateFunction();
        }
      },
    );
  }

  @override
  void dispose() {
    _throttleTimer?.cancel();
    super.dispose();
  }
}

/// StreamController avec throttling intégré
///
/// Limite le nombre d'événements émis par unité de temps
class ThrottledStreamController<T> {
  final StreamController<T> _controller = StreamController<T>.broadcast();
  final Duration throttleDuration;

  Timer? _throttleTimer;
  T? _lastValue;
  bool _canEmit = true;

  ThrottledStreamController({
    this.throttleDuration = const Duration(milliseconds: 500),
  });

  /// Stream throttlé
  Stream<T> get stream => _controller.stream;

  /// Ajoute une valeur au stream (avec throttling)
  void add(T value) {
    _lastValue = value;

    if (_canEmit) {
      _controller.add(value);
      _canEmit = false;

      _throttleTimer?.cancel();
      _throttleTimer = Timer(throttleDuration, () {
        _canEmit = true;
        // Émettre la dernière valeur si elle a changé pendant le throttle
        if (_lastValue != null && _lastValue != value) {
          _controller.add(_lastValue as T);
        }
      });
    }
  }

  /// Ferme le controller
  void close() {
    _throttleTimer?.cancel();
    _controller.close();
  }

  /// Vérifie si le stream est fermé
  bool get isClosed => _controller.isClosed;
}

/// Extension pour ajouter le throttling aux Streams
extension StreamThrottleExtension<T> on Stream<T> {
  /// Throttle le stream avec une durée donnée
  ///
  /// Limite le nombre d'événements émis par le stream.
  /// Seul le premier événement de chaque période est émis.
  Stream<T> throttle(Duration duration) {
    Timer? timer;
    bool canEmit = true;

    return transform(
      StreamTransformer<T, T>.fromHandlers(
        handleData: (data, sink) {
          if (canEmit) {
            sink.add(data);
            canEmit = false;

            timer?.cancel();
            timer = Timer(duration, () {
              canEmit = true;
            });
          }
        },
        handleDone: (sink) {
          timer?.cancel();
          sink.close();
        },
      ),
    );
  }

  /// Debounce le stream avec une durée donnée
  ///
  /// Émet seulement l'événement après qu'aucun nouvel événement
  /// n'ait été reçu pendant la durée spécifiée.
  Stream<T> debounce(Duration duration) {
    Timer? timer;

    return transform(
      StreamTransformer<T, T>.fromHandlers(
        handleData: (data, sink) {
          timer?.cancel();
          timer = Timer(duration, () {
            sink.add(data);
          });
        },
        handleDone: (sink) {
          timer?.cancel();
          sink.close();
        },
      ),
    );
  }
}

/// Builder widget avec throttling intégré
///
/// Ne rebuild le widget qu'après un délai minimum entre deux updates
class ThrottledBuilder extends StatefulWidget {
  final Duration throttleDuration;
  final Stream<dynamic> stream;
  final Widget Function(BuildContext context, AsyncSnapshot<dynamic> snapshot)
      builder;

  const ThrottledBuilder({
    super.key,
    required this.stream,
    required this.builder,
    this.throttleDuration = const Duration(milliseconds: 500),
  });

  @override
  State<ThrottledBuilder> createState() => _ThrottledBuilderState();
}

class _ThrottledBuilderState extends State<ThrottledBuilder> {
  late Stream<dynamic> _throttledStream;

  @override
  void initState() {
    super.initState();
    _throttledStream = widget.stream.throttle(widget.throttleDuration);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _throttledStream,
      builder: widget.builder,
    );
  }
}
