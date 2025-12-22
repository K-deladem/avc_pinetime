// ============================================================================
// models/connection_event.dart

class ConnectionEvent {
  final String id;
  final String armSide; // 'left' ou 'right'
  final ConnectionEventType type; // connected, disconnected, reconnecting
  final DateTime timestamp;
  final String? reason; // raison de la déconnexion si applicable
  final int? durationSeconds; // durée de la connexion si déconnecté
  final String? errorMessage; // message d'erreur si applicable
  final int? batteryAtConnection; // batterie au moment de la connexion
  final int? rssiAtConnection; // signal au moment de la connexion

  ConnectionEvent({
    String? id,
    required this.armSide,
    required this.type,
    required this.timestamp,
    this.reason,
    this.durationSeconds,
    this.errorMessage,
    this.batteryAtConnection,
    this.rssiAtConnection,
  }) : id = id ?? _generateId();

  static String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'armSide': armSide,
    'type': type.toString().split('.').last,
    'timestamp': timestamp.toIso8601String(),
    'reason': reason,
    'durationSeconds': durationSeconds,
    'errorMessage': errorMessage,
    'batteryAtConnection': batteryAtConnection,
    'rssiAtConnection': rssiAtConnection,
  };

  factory ConnectionEvent.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String;
    final type = ConnectionEventType.values.firstWhere(
          (e) => e.toString().split('.').last == typeString,
      orElse: () => ConnectionEventType.connected,
    );

    return ConnectionEvent(
      id: json['id'] as String,
      armSide: json['armSide'] as String,
      type: type,
      timestamp: DateTime.parse(json['timestamp'] as String),
      reason: json['reason'] as String?,
      durationSeconds: json['durationSeconds'] as int?,
      errorMessage: json['errorMessage'] as String?,
      batteryAtConnection: json['batteryAtConnection'] as int?,
      rssiAtConnection: json['rssiAtConnection'] as int?,
    );
  }

  String get typeLabel {
    switch (type) {
      case ConnectionEventType.connected:
        return 'Connected';
      case ConnectionEventType.disconnected:
        return 'Disconnected';
      case ConnectionEventType.reconnecting:
        return 'Reconnecting';
      case ConnectionEventType.connectionFailed:
        return 'Connection Failed';
    }
  }

  String get displayText {
    final time = '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';

    switch (type) {
      case ConnectionEventType.connected:
        return '$time - Connected (Battery: $batteryAtConnection%, Signal: ${rssiAtConnection}dBm)';
      case ConnectionEventType.disconnected:
        return '$time - Disconnected (Reason: $reason, Duration: ${_formatDuration(durationSeconds)})';
      case ConnectionEventType.reconnecting:
        return '$time - Reconnecting... (Reason: $reason)';
      case ConnectionEventType.connectionFailed:
        return '$time - Connection Failed ($errorMessage)';
    }
  }

  static String _formatDuration(int? seconds) {
    if (seconds == null) return 'Unknown';
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) return '${(seconds / 60).toStringAsFixed(1)}m';
    return '${(seconds / 3600).toStringAsFixed(1)}h';
  }
}

enum ConnectionEventType {
  connected,
  disconnected,
  reconnecting,
  connectionFailed,
}

class ConnectionStatistics {
  final String armSide;
  final int totalConnections;
  final int totalDisconnections;
  final Duration averageConnectionDuration;
  final Duration longestConnectionDuration;
  final int failedConnectionAttempts;
  final DateTime? lastConnected;
  final DateTime? lastDisconnected;
  final double uptime; // pourcentage

  ConnectionStatistics({
    required this.armSide,
    required this.totalConnections,
    required this.totalDisconnections,
    required this.averageConnectionDuration,
    required this.longestConnectionDuration,
    required this.failedConnectionAttempts,
    this.lastConnected,
    this.lastDisconnected,
    required this.uptime,
  });

  Map<String, dynamic> toJson() => {
    'armSide': armSide,
    'totalConnections': totalConnections,
    'totalDisconnections': totalDisconnections,
    'averageConnectionDurationSeconds': averageConnectionDuration.inSeconds,
    'longestConnectionDurationSeconds': longestConnectionDuration.inSeconds,
    'failedConnectionAttempts': failedConnectionAttempts,
    'lastConnected': lastConnected?.toIso8601String(),
    'lastDisconnected': lastDisconnected?.toIso8601String(),
    'uptime': uptime,
  };

  String get formattedUptime => '${(uptime * 100).toStringAsFixed(1)}%';

  String get formattedAverageDuration =>
      _formatDurationLong(averageConnectionDuration);

  String get formattedLongestDuration =>
      _formatDurationLong(longestConnectionDuration);

  static String _formatDurationLong(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}