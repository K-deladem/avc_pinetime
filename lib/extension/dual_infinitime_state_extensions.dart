// Helper pour obtenir le firmware sélectionné pour un bras
import 'package:flutter_bloc_app_template/bloc/infinitime/dual_infinitime_state.dart';
import 'package:flutter_bloc_app_template/models/arm_side.dart';
import 'package:infinitime_dfu_library/infinitime_dfu_library.dart';

extension DualInfiniTimeStateExtensions on DualInfiniTimeState {
  FirmwareInfo? getSelectedFirmware(ArmSide side) {
    return selectedFirmwares[side];
  }

  bool hasFirmwareSelected(ArmSide side) {
    return selectedFirmwares[side] != null;
  }

  bool canInstallFirmware(ArmSide side) {
    final arm = side == ArmSide.left ? left : right;
    return arm.connected &&
        !arm.dfuRunning &&
        hasFirmwareSelected(side);
  }
}