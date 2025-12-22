# InfiniTime DFU Library

Une library Flutter complète et modulaire pour gérer les mises à jour DFU (Device Firmware Update) et la communication BLE avec les montres InfiniTime/PineTime.

## Caractéristiques

- **Gestion complète DFU**: Tout le protocole DFU Nordic pour les mises à jour firmware
- **Communication BLE**: Session InfiniTime pour lire les capteurs et envoyer des données
- **Gestion des firmware**: Validation, détection de version, support ZIP/BIN
- **Injection de dépendances**: Aucun hardcoding - définissez vos propres sources
- **Streams réactifs**: Observez les changements de statut et progression
- **Gestion MTU adaptative**: Négocie automatiquement la taille des paquets
- **Retry logique**: Reconnexion automatique en cas d'erreur
- **Support multi-service**: Batterie, HR, pas, température, etc.

## Installation

Ajoutez à votre `pubspec.yaml`:

```yaml
dependencies:
  infinitime_dfu_library:
    path: ../path/to/infinitime_dfu_library
  flutter_reactive_ble: ^5.4.0
  archive: ^3.4.0
```

## Usage Rapide

### 1. Définir une source de firmware

```dart
import 'package:infinitime_dfu_library/infinitime_dfu_library.dart';

class MyFirmwareSource extends FirmwareSourceDelegate {
  @override
  Future<List<String>> getAvailableFirmwares() async {
    return [
      'assets/firmware/infinitime-1.14.0.zip',
      'assets/firmware/infinitime-1.15.0.zip',
    ];
  }

  @override
  FirmwareInfo? getFirmwareInfo(String assetPath) {
    // Optional: retourner des infos custom
    return null; // Utiliser la détection automatique
  }

  @override
  void onFirmwareLoaded(FirmwareInfo info) {
    print('Firmware chargé: ${info.shortDescription}');
  }

  @override
  void onFirmwareError(String assetPath, String error) {
    print('Erreur firmware: $error');
  }
}
```

### 2. Gérer les firmware

```dart
final manager = FirmwareManager(MyFirmwareSource());

// Charger tous les firmware disponibles
final firmwares = await manager.loadAvailableFirmwares();

for (var fw in firmwares) {
  print('${fw.shortDescription}');
}

// Valider un firmware
final validation = await manager.validateFirmwareAsset('assets/firmware/infinitime-1.14.0.zip');
if (validation.isValid) {
  print('Firmware valide');
} else {
  print('Erreurs: ${validation.criticalIssues}');
}

// Charger les fichiers DFU
final dfuFiles = await manager.loadFirmwareFiles('assets/firmware/infinitime-1.14.0.zip');
```

### 3. Effectuer une mise à jour DFU

```dart
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

final ble = FlutterReactiveBle();
final dfuService = DfuServiceManager(ble);

// Écouter les mises à jour
dfuService.statusStream.listen((status) {
  print('DFU Status: $status');
});

dfuService.progressStream.listen((progress) {
  print('Progression: ${(progress * 100).toStringAsFixed(1)}%');
});

dfuService.stateStream.listen((state) {
  print('État: $state');
});

// Connecter en mode DFU
final connected = await dfuService.connectToDevice('device-id');

if (connected) {
  // Effectuer la mise à jour
  final dfuFiles = await manager.loadFirmwareFiles('assets/firmware/infinitime-1.14.0.zip');
  final success = await dfuService.performCompleteFirmwareUpdate(dfuFiles);
  
  if (success) {
    print('Mise à jour réussie!');
  }
}

await dfuService.dispose();
```

### 4. Communication avec la montre

```dart
final ble = FlutterReactiveBle();
final session = InfiniTimeSession(ble, 'device-id');

// Connecter et initialiser
if (await session.connectAndSetup()) {
  // Écouter les événements
  session.batteryStream.listen((level) {
    print('Batterie: $level%');
  });

  session.heartRateStream.listen((hr) {
    print('Fréquence cardiaque: $hr bpm');
  });

  session.stepCountStream.listen((steps) {
    print('Pas: $steps');
  });

  // Envoyer l'heure
  await session.sendTime();

  // Écrire une caractéristique custom
  await session.writeCharacteristic(
    InfiniTimeUuids.musicService,
    InfiniTimeUuids.musicEvent,
    [MusicEvent.play.value],
  );

  // Lire une caractéristique
  final data = await session.readCharacteristic(
    InfiniTimeUuids.batteryService,
    InfiniTimeUuids.batteryLevel,
  );

  print('Batterie: ${DataParser.parseBatteryLevel(data)}%');

  await session.disconnect();
}
```

## API Détaillée

### FirmwareManager

**Constructeur**
```dart
FirmwareManager(FirmwareSourceDelegate delegate)
```

**Méthodes**
- `loadAvailableFirmwares()` - Charger liste des firmware
- `getFirmwareInfo(String assetPath)` - Info détaillée
- `validateFirmwareAsset(String assetPath)` - Valider
- `loadFirmwareFiles(String assetPath)` - Charger fichiers DFU
- `clearCache()` - Vider le cache

### DfuServiceManager

**Constructeur**
```dart
DfuServiceManager(FlutterReactiveBle ble)
```

**Propriétés**
- `isConnected` - Connecté?
- `isUpdateRunning` - Mise à jour en cours?
- `statusStream` - Flux de statut
- `progressStream` - Flux de progression (0.0-1.0)
- `stateStream` - Flux d'état (DfuUpdateState)

**Méthodes**
- `connectToDevice(String deviceId)` - Connecter
- `performCompleteFirmwareUpdate(DfuFiles dfuFiles)` - Mettre à jour
- `cancelUpdate()` - Annuler
- `dispose()` - Nettoyer

**Callbacks**
- `onStatusUpdate(StatusCallback callback)` - Statut
- `onProgressUpdate(ProgressCallback callback)` - Progression
- `onError(ErrorCallback callback)` - Erreur

### InfiniTimeSession

**Constructeur**
```dart
InfiniTimeSession(FlutterReactiveBle ble, String deviceId)
```

**Propriétés**
- `isConnected` - Connecté?
- `batteryStream` - Niveau batterie (0-100)
- `heartRateStream` - Fréquence cardiaque (bpm)
- `stepCountStream` - Nombre de pas
- `motionStream` - Valeurs accéléromètre
- `temperatureStream` - Température (°C)
- `connectionStream` - État connexion

**Méthodes**
- `connectAndSetup()` - Connecter et souscrire
- `writeCharacteristic()` - Écrire
- `writeCharacteristicWithoutResponse()` - Écrire sans réponse
- `readCharacteristic()` - Lire
- `subscribeToCharacteristic()` - Souscrire
- `sendTime(DateTime? dateTime)` - Envoyer heure
- `disconnect()` - Déconnecter
- `dispose()` - Nettoyer

**Callbacks**
- `onBatteryChanged(BatteryCallback callback)`
- `onHeartRateChanged(HeartRateCallback callback)`
- `onStepCountChanged(StepCountCallback callback)`
- `onMotionChanged(MotionCallback callback)`
- `onTemperatureChanged(TemperatureCallback callback)`
- `onConnectionChanged(ConnectionCallback callback)`

### Utilitaires

#### InfiniTimeUuids
Tous les UUIDs standard BLE et InfiniTime.

```dart
InfiniTimeUuids.batteryService    // Service batterie
InfiniTimeUuids.hrService         // Service HR
InfiniTimeUuids.dfuService        // Service DFU
InfiniTimeUuids.musicService      // Service musique
InfiniTimeUuids.navService        // Service navigation
// ... et beaucoup plus
```

#### DataParser
Parser les données des capteurs.

```dart
int level = DataParser.parseBatteryLevel(data);
int hr = DataParser.parseHeartRate(data);
int steps = DataParser.parseStepCount(data);
double temp = DataParser.parseTemperature(data);
Map motion = DataParser.parseMotionValues(data);
```

#### DfuProtocolHelper
Protocole DFU low-level.

```dart
List<int> packet = DfuProtocolHelper.createStartDfuPacket();
List<int> sizePacket = DfuProtocolHelper.createSizePacket(firmwareSize: 500000);
int effectiveMtu = DfuProtocolHelper.calculateEffectiveMtu(247);
```

#### InfiniTimeUtil
Agrégation centralisée (parsers + UUIDs + DFU).

```dart
InfiniTimeUtil.parseBatteryLevel(data)
InfiniTimeUtil.uuids.batteryService
InfiniTimeUtil.createStartDfuPacket()
```

## Enumerations

### DfuUpdateState
- `idle` - Idle
- `preparing` - Préparation
- `initialized` - Initialisé
- `sending` - Envoi des données
- `validating` - Validation
- `activating` - Activation
- `completed` - Complété
- `failed` - Erreur
- `cancelled` - Annulé

### DeviceConnectionState
- `connecting`
- `connected`
- `disconnecting`
- `disconnected`
- `unknown`

### MusicEvent
- `play`
- `pause`
- `next`
- `previous`
- `volumeUp`
- `volumeDown`

### NavDirection
- `turnLeft`
- `turnRight`
- `turnSharpLeft`
- `turnSharpRight`
- `turnSlightLeft`
- `turnSlightRight`
- `continueRoute`
- `uTurn`
- `finish`

## Architecture

```
lib/
├── infinitime_dfu_library.dart     # Exports principaux
└── src/
    ├── models/                      # Modèles de données
    │   ├── infinitime_uuids.dart   # UUIDs BLE
    │   ├── firmware_info.dart      # Info firmware
    │   ├── firmware_validation_result.dart
    │   ├── dfu_files.dart          # Fichiers DFU
    │   └── enums.dart              # Énumérations
    ├── services/                    # Services BLE
    │   ├── infinitime_session.dart  # Session de communication
    │   ├── dfu_service_manager.dart # Service DFU
    │   └── firmware_manager.dart    # Gestion des firmwares
    └── utils/                       # Utilitaires
        ├── infinitime_util.dart     # Agrégation
        ├── data_parser.dart         # Parser de données
        └── dfu_protocol_helper.dart # Protocole DFU
```

## Injection de Dépendances

La library utilise le pattern Delegate pour éviter le hardcoding:

```dart
abstract class FirmwareSourceDelegate {
  Future<List<String>> getAvailableFirmwares();
  FirmwareInfo? getFirmwareInfo(String assetPath) => null;
  void onFirmwareLoaded(FirmwareInfo info) {}
  void onFirmwareError(String assetPath, String error) {}
}
```

Vous devez implémenter cette interface pour fournir votre propre source de firmware.

## Gestion des Erreurs

```dart
try {
  final dfuFiles = await manager.loadFirmwareFiles(assetPath);
  final success = await dfuService.performCompleteFirmwareUpdate(dfuFiles);
} catch (e) {
  print('Erreur: $e');
}

// Ou utiliser les streams
dfuService.onError((error) {
  print('Erreur DFU: $error');
});
```

## Performance

- **MTU Adaptatif**: Négocie la taille optimale des paquets
- **Délais Adaptatifs**: Ajuste les délais selon le MTU
- **Cache**: Met en cache les firmware validés
- **Retry Logic**: Reconnecte automatiquement en cas d'erreur
- **Streaming**: Utilise les streams pour minimiser la mémoire

## Compatibilité

- Flutter 3.0+
- Dart 2.19+
- flutter_reactive_ble 5.4.0+
- archive 3.4.0+

## Licence

MIT

## Support

Pour les problèmes ou questions, consultez la documentation ou les exemples.
