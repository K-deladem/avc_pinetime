// lib/src/utils/data_parser.dart

/// Utilitaire pour parser les données reçues des capteurs InfiniTime
class DataParser {
  /// Parse les données de batterie (BLE Battery Service)
  static int parseBatteryLevel(List<int> data) {
    if (data.isEmpty) return 0;
    return data[0].clamp(0, 100);
  }

  /// Parse les données de fréquence cardiaque (BLE Heart Rate Service)
  /// Retourne la fréquence cardiaque en bpm
  static int parseHeartRate(List<int> data) {
    if (data.isEmpty) return 0;
    
    final flags = data[0];
    final is16Bit = (flags & 0x01) != 0;

    if (!is16Bit && data.length >= 2) {
      return data[1];
    }
    if (is16Bit && data.length >= 3) {
      return (data[2] << 8) | data[1];
    }
    return 0;
  }

  /// Parse le nombre de pas (Motion Service)
  /// Format: uint32 little-endian
  static int parseStepCount(List<int> data) {
    if (data.length < 4) return 0;
    return data[0] | (data[1] << 8) | (data[2] << 16) | (data[3] << 24);
  }

  /// Parse les coordonnées du capteur de mouvement (accéléromètre/gyroscope)
  /// Retourne un Map avec x, y, z
  static Map<String, int> parseMotionValues(List<int> data) {
    if (data.length < 6) {
      return {'x': 0, 'y': 0, 'z': 0};
    }
    
    return {
      'x': (data[0] << 8) | data[1],
      'y': (data[2] << 8) | data[3],
      'z': (data[4] << 8) | data[5],
    };
  }

  /// Parse la température depuis le Weather Service
  /// Format: int16 en centièmes de degrés Celsius
  static double parseTemperature(List<int> data) {
    if (data.length < 2) return 0.0;
    final tempCelsius = (data[0]) | (data[1] << 8);
    return tempCelsius / 100.0;
  }

  /// Parse l'heure depuis le Current Time Service
  static DateTime? parseCurrentTime(List<int> data) {
    if (data.length < 7) return null;
    
    try {
      final year = (data[0]) | (data[1] << 8);
      final month = data[2];
      final day = data[3];
      final hour = data[4];
      final minute = data[5];
      final second = data[6];
      
      return DateTime(year, month, day, hour, minute, second);
    } catch (e) {
      return null;
    }
  }

  /// Convertit une liste de bytes en hexadécimal pour le debug
  static String bytesToHex(List<int> data) {
    return data
        .map((b) => '0x${b.toRadixString(16).padLeft(2, '0').toUpperCase()}')
        .join(' ');
  }

  /// Convertit une liste de bytes en String ASCII
  static String bytesToAscii(List<int> data) {
    return data.map((b) => String.fromCharCode(b)).join('');
  }

  /// Convertit une liste de bytes en String UTF-8
  static String bytesToUtf8(List<int> data) {
    try {
      return String.fromCharCodes(data);
    } catch (e) {
      return bytesToHex(data);
    }
  }

  /// Extrait un uint8 à partir d'une position
  static int readUint8(List<int> data, int offset) {
    if (offset >= data.length) return 0;
    return data[offset];
  }

  /// Extrait un uint16 little-endian à partir d'une position
  static int readUint16LE(List<int> data, int offset) {
    if (offset + 1 >= data.length) return 0;
    return (data[offset]) | (data[offset + 1] << 8);
  }

  /// Extrait un uint32 little-endian à partir d'une position
  static int readUint32LE(List<int> data, int offset) {
    if (offset + 3 >= data.length) return 0;
    return (data[offset]) | 
           (data[offset + 1] << 8) | 
           (data[offset + 2] << 16) | 
           (data[offset + 3] << 24);
  }

  /// Extrait un int16 little-endian signé à partir d'une position
  static int readInt16LE(List<int> data, int offset) {
    int value = readUint16LE(data, offset);
    if ((value & 0x8000) != 0) {
      value = -(0x10000 - value);
    }
    return value;
  }

  /// Extrait un int32 little-endian signé à partir d'une position
  static int readInt32LE(List<int> data, int offset) {
    int value = readUint32LE(data, offset);
    if ((value & 0x80000000) != 0) {
      value = -(0x100000000 - value);
    }
    return value;
  }
}
