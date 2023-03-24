class Time {
  final int hour;
  final int minute;

  Time(this.hour, this.minute);

  @override
  String toString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}
