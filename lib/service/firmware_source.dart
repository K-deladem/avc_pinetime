import 'package:flutter/cupertino.dart';
import 'package:infinitime_dfu_library/infinitime_dfu_library.dart';

class FirmwareSource extends FirmwareSourceDelegate {
  @override
  Future<List<String>> getAvailableFirmwares() async {
    return [
      'assets/firmware/pinetime-mcuboot-app-dfu-1.15.2.zip',
    ];
  }

  @override
  FirmwareInfo? getFirmwareInfo(String assetPath) {
    return null;
  }

  @override
  void onFirmwareLoaded(FirmwareInfo info) {
    debugPrint('[FIRMWARE] Loaded: ${info.shortDescription}');
  }

  @override
  void onFirmwareError(String assetPath, String error) {
    debugPrint('[FIRMWARE ERROR] $assetPath: $error');
  }
}
