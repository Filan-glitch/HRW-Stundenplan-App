import 'dart:developer';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timetable/service/db/migrate.dart';

import '../../model/constants.dart';

Future<Database> openDB() async {
  String databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'timetable.db');
  return openDatabase(
    path,
    version: DB_VERSION,
    onCreate: (Database database, int version) async {
      dbInit.forEach((element) async => await database.execute(element));
    },
    onUpgrade: (Database db, int oldVersion, int newVersion) async {
      log("Upgrading database from version $oldVersion to $newVersion");
      for (int i = oldVersion; i < newVersion; i++) {
        await db.execute(dbMigrate[i + 1]);
      }
    },
  );
}
