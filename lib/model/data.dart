import 'break.dart';
import 'event.dart';
import 'time.dart';

List<dynamic> _monday = [
  Event(
    module: "Digitale Signalverarbeitung",
    eventType: "Vorlesung",
    startTime: Time(8, 50),
    endTime: Time(11, 20),
    room: "Hörsaal 4",
  ),
  Break(),
  Event(
    module: "Sicherheit & Zuverlässigkeit",
    eventType: "Vorlesung",
    startTime: Time(12, 20),
    endTime: Time(14, 50),
    room: "Hörsaal 3",
  ),
];

List<dynamic> _tuesday = [
  Event(
    module: "Softwaretechnik",
    eventType: "Vorlesung",
    startTime: Time(11, 30),
    endTime: Time(14, 0),
    room: "Hörsaal 3",
  ),
  Break(),
  Event(
    module: "Programmierung 2",
    eventType: "Arbeiten",
    startTime: Time(15, 0),
    endTime: Time(16, 35),
    room: "03.216",
  ),
];

List<dynamic> _wednesday = [
  Event(
    module: "Softwaretechnik",
    eventType: "Übung",
    startTime: Time(9, 45),
    endTime: Time(11, 20),
    room: "03.216",
  ),
  Break(),
  Event(
    module: "Sicherheit & Zuverlässigkeit",
    eventType: "Übung",
    startTime: Time(11, 30),
    endTime: Time(12, 15),
    room: "Seminarraum 6 (02.202)",
  ),
  Event(
    module: "Sicherheit & Zuverlässigkeit",
    eventType: "Praktikum",
    startTime: Time(12, 20),
    endTime: Time(13, 5),
    room: "Seminarraum 6 (02.202)",
  ),
];

List<dynamic> _thursday = [
  Event(
    module: "Digitale Signalverarbeitung",
    eventType: "Übung",
    startTime: Time(9, 45),
    endTime: Time(10, 30),
    room: "Seminarraum 4",
  ),
  Event(
    module: "Digitale Signalverarbeitung",
    eventType: "Praktikum",
    startTime: Time(10, 35),
    endTime: Time(11, 20),
    room: "Seminarraum 4",
  ),
  Break(),
  Event(
    module: "Betriebssysteme",
    eventType: "Vorlesung",
    startTime: Time(12, 20),
    endTime: Time(14, 00),
    room: "Hörsaal 3",
  ),
];

List<dynamic> _friday = [
  Event(
    module: "Wirtschaft & Recht",
    eventType: "Vorlesung",
    startTime: Time(8, 0),
    endTime: Time(11, 20),
    room: "Hörsaal 4",
  ),
  Break(),
  Event(
    module: "Betriebssysteme",
    eventType: "Übung",
    startTime: Time(12, 20),
    endTime: Time(14, 00),
    room: "02.210",
  ),
];

List<List<dynamic>> timetable = [
  _monday,
  _tuesday,
  _wednesday,
  _thursday,
  _friday,
];
