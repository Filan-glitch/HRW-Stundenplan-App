enum Campus {
  muelheim("Mülheim"),
  bottrop("Bottrop");

  const Campus(this.name);
  final String name;
  String get text => name;
  static Campus getByValue(String value) {
    switch (value) {
      case "Mülheim":
        return muelheim;
      case "Bottrop":
        return bottrop;
      default:
        return muelheim;
    }
  }
}
