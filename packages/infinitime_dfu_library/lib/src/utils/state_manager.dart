// lib/src/utils/state_manager.dart
import 'package:flutter/foundation.dart';
import '../models/enums.dart';
import '../exceptions/dfu_exceptions.dart';

/// Gestionnaire d'états avec validation des transitions
class DfuStateManager {
  DfuUpdateState _currentState = DfuUpdateState.idle;
  DateTime? _stateChangeTime;
  final List<(DfuUpdateState from, DfuUpdateState to, DateTime time)> _history = [];

  // Callbacks
  Function(DfuUpdateState)? _onStateChanged;
  Function(DfuUpdateState, DfuUpdateState)? _onInvalidTransition;

  /// Transitions valides entre états
  /// Format: depuis → ensemble des états vers lesquels on peut aller
  static const Map<DfuUpdateState, Set<DfuUpdateState>> validTransitions = {
    DfuUpdateState.idle: {
      DfuUpdateState.preparing,
      DfuUpdateState.cancelled,
    },
    DfuUpdateState.preparing: {
      DfuUpdateState.initialized,
      DfuUpdateState.failed,
      DfuUpdateState.cancelled,
    },
    DfuUpdateState.initialized: {
      DfuUpdateState.sending,
      DfuUpdateState.failed,
      DfuUpdateState.cancelled,
    },
    DfuUpdateState.sending: {
      DfuUpdateState.validating,
      DfuUpdateState.failed,
      DfuUpdateState.cancelled,
    },
    DfuUpdateState.validating: {
      DfuUpdateState.activating,
      DfuUpdateState.failed,
      DfuUpdateState.cancelled,
    },
    DfuUpdateState.activating: {
      DfuUpdateState.completed,
      DfuUpdateState.failed,
      DfuUpdateState.cancelled,
    },
    DfuUpdateState.completed: {
      DfuUpdateState.idle,
    },
    DfuUpdateState.failed: {
      DfuUpdateState.idle,
      DfuUpdateState.preparing, // Retry possible
    },
    DfuUpdateState.cancelled: {
      DfuUpdateState.idle,
    },
  };

  DfuUpdateState get currentState => _currentState;
  DateTime? get stateChangeTime => _stateChangeTime;
  List<(DfuUpdateState from, DfuUpdateState to, DateTime time)> get history =>
      List.unmodifiable(_history);

  /// Obtient la durée depuis le dernier changement d'état
  Duration get timeSinceStateChange {
    if (_stateChangeTime == null) return Duration.zero;
    return DateTime.now().difference(_stateChangeTime!);
  }

  /// Défini le callback de changement d'état
  void onStateChanged(Function(DfuUpdateState) callback) {
    _onStateChanged = callback;
  }

  /// Défini le callback de transition invalide
  void onInvalidTransition(
      Function(DfuUpdateState from, DfuUpdateState to) callback,
      ) {
    _onInvalidTransition = callback;
  }

  /// Vérifie si une transition est valide
  bool canTransition(DfuUpdateState newState) {
    final validStates = validTransitions[_currentState];
    return validStates?.contains(newState) ?? false;
  }

  /// Change l'état avec validation
  /// Lève une [DfuStateException] si la transition est invalide
  void setState(DfuUpdateState newState, {String? reason}) {
    if (_currentState == newState) {
      if (kDebugMode) {
        print('[DfuStateManager] État déjà: $_currentState');
      }
      return;
    }

    if (!canTransition(newState)) {
      _onInvalidTransition?.call(_currentState, newState);
      throw DfuStateException(
        'Transition invalide: $_currentState → $newState' +
            (reason != null ? '\nRaison: $reason' : ''),
        currentState: _currentState.toString(),
        attemptedState: newState.toString(),
      );
    }

    final previousState = _currentState;
    _currentState = newState;
    _stateChangeTime = DateTime.now();

    _history.add((previousState, newState, _stateChangeTime!));

    _onStateChanged?.call(newState);

    if (kDebugMode) {
      print('[DfuStateManager] $previousState → $newState' +
          (reason != null ? ' ($reason)' : ''));
    }
  }

  /// Retourne à l'état idle
  void reset({String? reason}) {
    _currentState = DfuUpdateState.idle;
    _stateChangeTime = DateTime.now();
    _onStateChanged?.call(DfuUpdateState.idle);

    if (kDebugMode) {
      print('[DfuStateManager] Réinitialisation' +
          (reason != null ? ' ($reason)' : ''));
    }
  }

  /// Marquer comme échoué avec détails
  void setFailed(String reason, {DfuException? exception}) {
    try {
      setState(DfuUpdateState.failed, reason: reason);
    } catch (e) {
      // Forcer le changement vers failed si possible
      if (canTransition(DfuUpdateState.failed)) {
        _currentState = DfuUpdateState.failed;
        _stateChangeTime = DateTime.now();
        _onStateChanged?.call(DfuUpdateState.failed);
      }
    }

    if (kDebugMode) {
      print('[DfuStateManager] FAILED: $reason');
      if (exception != null) {
        print('Exception: $exception');
      }
    }
  }

  /// Vérifie si nous sommes dans un état de completion
  bool get isCompleted =>
      _currentState == DfuUpdateState.completed ||
          _currentState == DfuUpdateState.failed ||
          _currentState == DfuUpdateState.cancelled;

  /// Vérifie si nous sommes dans un état actif
  bool get isActive =>
      _currentState == DfuUpdateState.sending ||
          _currentState == DfuUpdateState.validating ||
          _currentState == DfuUpdateState.activating;

  /// Affiche un diagramme des transitions valides
  static void printStateDiagram() {
    print('\n=== DFU State Transition Diagram ===\n');
    validTransitions.forEach((from, toSet) {
      final transitions = toSet.map((to) => to.toString().split('.').last).join(', ');
      print('${from.toString().split('.').last} → [$transitions]');
    });
    print('\n================================\n');
  }

  /// Retourne l'historique formaté
  String getFormattedHistory() {
    if (_history.isEmpty) return 'Aucune transition';

    return _history
        .map((entry) {
      final from = entry.$1.toString().split('.').last;
      final to = entry.$2.toString().split('.').last;
      final time = entry.$3.toString().split('.').first;
      return '$from → $to ($time)';
    })
        .join('\n');
  }

  /// Reset complet
  void clear() {
    _currentState = DfuUpdateState.idle;
    _stateChangeTime = null;
    _history.clear();
    _onStateChanged = null;
    _onInvalidTransition = null;
  }
}

/// Builder pour faciliter les transitions d'état guidées
class StateTransitionBuilder {
  final DfuStateManager _manager;
  final List<DfuUpdateState> _expectedSequence;

  StateTransitionBuilder(this._manager, this._expectedSequence);

  /// Exécute l'opération et fait la transition si succès
  Future<T> execute<T>(
      Future<T> Function() operation,
      DfuUpdateState nextState, {
        String? reason,
      }) async {
    try {
      final result = await operation();
      _manager.setState(nextState, reason: reason ?? 'Operation succeeded');
      return result;
    } catch (e) {
      _manager.setFailed('Opération échouée: $e',
          exception: e is DfuException ? e : null);
      rethrow;
    }
  }

  /// Vérifie que la séquence est respectée
  bool isSequenceRespected() {
    return _manager.currentState == _expectedSequence.last;
  }

  /// Affiche les états attendus restants
  String getRemainingSteps() {
    final currentIndex = _expectedSequence.indexOf(_manager.currentState);
    if (currentIndex == -1) return 'Séquence non alignée';

    final remaining = _expectedSequence.sublist(currentIndex + 1);
    return remaining.map((s) => s.toString().split('.').last).join(' → ');
  }
}

/// State Machine avec support des états partagés
class DfuStateMachine {
  final DfuStateManager _manager;
  final Map<DfuUpdateState, void Function()> _stateHandlers = {};

  DfuStateMachine(this._manager);

  /// Enregistre un handler pour un état
  void on(DfuUpdateState state, void Function() handler) {
    _stateHandlers[state] = handler;
  }

  /// Déclenche le handler pour l'état actuel
  void handleCurrentState() {
    final handler = _stateHandlers[_manager.currentState];
    handler?.call();
  }

  /// Transition avec handler automatique
  void transitionTo(DfuUpdateState newState, {String? reason}) {
    _manager.setState(newState, reason: reason);
    handleCurrentState();
  }
}