import 'time.dart';

class Event {
  String module;
  String eventType;
  Time startTime;
  Time endTime;
  String room;

  Event({
    required this.module,
    required this.eventType,
    required this.startTime,
    required this.endTime,
    required this.room,
  });

  Mode getMode() {
    int hour = DateTime.now().hour;
    int minute = DateTime.now().minute;

    bool isAfterStart = hour > startTime.hour ||
        hour == startTime.hour && minute >= startTime.minute;

    bool isBeforeEnd =
        hour < endTime.hour || hour == endTime.hour && minute <= endTime.minute;

    if (isAfterStart && isBeforeEnd) {
      return Mode.active;
    } else if (isAfterStart && !isBeforeEnd) {
      return Mode.done;
    } else {
      return Mode.normal;
    }
  }
}

enum Mode { normal, active, done }
