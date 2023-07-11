import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sqflite/sqflite.dart';

import '../../model/module.dart';
import '../../model/redux/actions.dart';
import '../../model/redux/store.dart';
import 'connection.dart';

Future<void> loadGradesFromStorage() async {
  try {
    Database db = await openDB();

    List<Map<String, dynamic>> result = await db.query('Grades');
    List<Module> modules = [];

    for (Map<String, dynamic> item in result) {
      modules.add(Module.fromDB(item));
    }

    store.dispatch(Action(
      ActionTypes.setGrades,
      payload: modules,
    ));

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

Future<void> writeGradesToStorage() async {
  try {
    Database db = await openDB();

    for (Module module in store.state.modules) {
      await db.insert(
        'Grades',
        module.toDB(),
        conflictAlgorithm: ConflictAlgorithm.replace,
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
