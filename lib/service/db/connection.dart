import 'dart:developer';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../model/constants.dart';
import 'migrate.dart';

Future<Database> openDB() async {
  String databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'timetable.db');
  return openDatabase(
    path,
    version: DB_VERSION,
    onCreate: (Database database, int version) async {
      for (int i = 0; i < dbInit.length; i++) {
        await database.execute(dbInit[i]);
      }
    },
    onOpen: (Database database) async {
      for (int i = 0; i < dbInit.length; i++) {
        await database.execute(dbInit[i]);
      }
    },
    onUpgrade: (Database db, int oldVersion, int newVersion) async {
      log("Upgrading database from version $oldVersion to $newVersion");
      for (int i = oldVersion; i < newVersion; i++) {
        await db.execute(dbMigrate[i + 1]);
      }
    },
  );
}
