class Time implements Comparable<Time> {
  final int hour;
  final int minute;

  int get totalMinutes => hour * 60 + minute;

  const Time(this.hour, this.minute);

  @override
  String toString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  @override
  int compareTo(Time other) {
    return totalMinutes.compareTo(other.totalMinutes);
  }
}
