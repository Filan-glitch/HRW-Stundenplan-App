enum Weekday {
  monday(0),
  tuesday(1),
  wednesday(2),
  thursday(3),
  friday(4);

  const Weekday(this.value);
  final int value;
  String get text {
    switch (value) {
      case 0:
        return "Montag";
      case 1:
        return "Dienstag";
      case 2:
        return "Mittwoch";
      case 3:
        return "Donnerstag";
      case 4:
        return "Freitag";
      default:
        return "";
    }
  }

  static Weekday getByValue(int value) {
    return Weekday.values.firstWhere(
      (x) => x.value == value,
      orElse: () => Weekday.monday,
    );
  }

  static Weekday getByText(String text) {
    if (text.contains("Dienstag")) {
      return Weekday.tuesday;
    } else if (text.contains("Mittwoch")) {
      return Weekday.wednesday;
    } else if (text.contains("Donnerstag")) {
      return Weekday.thursday;
    } else if (text.contains("Freitag")) {
      return Weekday.friday;
    } else {
      return Weekday.monday;
    }
  }
}
