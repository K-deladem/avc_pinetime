enum InfoType {
  battery,
  step,
  rssi;

  static InfoType fromString(String value) {
    return InfoType.values.firstWhere(
          (e) => e.name == value,
      orElse: () => InfoType.battery,
    );
  }
}