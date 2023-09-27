import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

import '../model/event.dart';
import 'db/events.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (!Platform.isAndroid) return Future.value(false);

      // Initialisiere das FlutterLocalNotificationsPlugin
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      var initializationSettings = const InitializationSettings(
        android: AndroidInitializationSettings('notification_icon'),
        iOS: DarwinInitializationSettings(),
      );

      await flutterLocalNotificationsPlugin.initialize(initializationSettings);

      // Zeige die Benachrichtigung an
      var platformChannelSpecifics = const NotificationDetails(
        android: AndroidNotificationDetails(
          'TIMETABLE_REMINDER',
          'Terminerinnerung',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
        ),
        iOS: DarwinNotificationDetails(),
      );

      List<Event> events = await getNextEvents();

      for (Event event in events) {
        await flutterLocalNotificationsPlugin.show(
          Random().nextInt(100),
          'Kommende Veranstaltung',
          event.toString(),
          platformChannelSpecifics,
        );
      }

      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  });
}

Future<void> registerBackgroundService() {
  return Workmanager().registerPeriodicTask(
    "TIMETABLE_REMINDER_TASK",
    "Terminerinnerung",
    tag: "TIMETABLE_REMINDER_TASK",
    frequency: const Duration(minutes: 15),
  );
}

Future<void> unregisterBackgroundService() {
  return Workmanager().cancelByTag("TIMETABLE_REMINDER_TASK");
}
