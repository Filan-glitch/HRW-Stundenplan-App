import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sqflite/sqflite.dart';

import '../../model/event.dart';
import '../../model/redux/actions.dart';
import '../../model/redux/store.dart';
import '../storage.dart';
import 'connection.dart';

Future<void> loadDataFromStorage() async {
  try {
    Database db = await openDB();
    DateFormat formatter = DateFormat('dd/MM/yyyy');
    List<Map<String, dynamic>> result = await db.query('Events');
    Map<String, List<Event>> events = {};

    // fill empty weeks
    DateTime currentMonday =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
            .subtract(
      Duration(
        days: DateTime.now().weekday - 1,
      ),
    );

    String? mon = await loadDownloadedRange();
    if (mon != null) {
      DateTime lastFetchedWeek = formatter.parse(mon);

      while (!lastFetchedWeek.isBefore(currentMonday)) {
        events[formatter.format(currentMonday)] = [];
        currentMonday = currentMonday.add(const Duration(days: 7));
      }
    }

    DateTime oldEventDate = DateTime.now().subtract(const Duration(days: 7));
    for (Map<String, dynamic> item in result) {
      DateTime eventDate = formatter.parse(item['WeekFrom']);

      // Remove past events
      if (eventDate.isBefore(oldEventDate)) {
        await db.delete(
          'Events',
          where: 'EventID = ?',
          whereArgs: [item['EventID']],
        );
        continue;
      }

      Event event = Event.fromDB(item);

      // Add event to list
      if (!events.containsKey(event.weekFrom)) {
        events[item['WeekFrom']] = [];
      }
      events[event.weekFrom]!.add(event);
    }

    for (String date in events.keys) {
      store.dispatch(
        Action(
          ActionTypes.setEvents,
          payload: {
            "date": date,
            "events": events[date],
          },
        ),
      );
    }

    await db.close();
  } catch (e, stackTrace) {
    showToast('Es ist ein Fehler aufgetreten');
    if (kDebugMode) {
      print(e);
      print(stackTrace);
    }

    FirebaseCrashlytics.instance.recordError(e, stackTrace);
  }
}

Future<void> writeDataToStorage() async {
  try {
    DateFormat formatter = DateFormat('dd/MM/yyyy');
    DateTime? lastFetchedWeek;
    Database db = await openDB();

    for (String date in store.state.events.keys) {
      if (lastFetchedWeek == null ||
          formatter.parse(date).isAfter(lastFetchedWeek)) {
        lastFetchedWeek = formatter.parse(date);
      }

      for (Event event in store.state.events[date]!) {
        await db.insert(
          'Events',
          event.toDB(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    if (lastFetchedWeek != null) {
      await writeDownloadedRange(formatter.format(lastFetchedWeek));
    }

    await db.close();
  } catch (e, stackTrace) {
    showToast('Es ist ein Fehler aufgetreten');
    if (kDebugMode) {
      print(e);
      print(stackTrace);
    }
    FirebaseCrashlytics.instance.recordError(e, stackTrace);
  }
}
