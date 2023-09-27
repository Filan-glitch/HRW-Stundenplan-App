import 'package:flutter/material.dart';

import '../biometrics.dart';
import '../campus.dart';
import '../date_time_calculator.dart';
import '../event.dart';
import '../login_state.dart';
import '../module.dart';
import '../timetable_view.dart';

class AppState {
  ThemeMode activeTheme = ThemeMode.system;
  bool dataLoaded = false;
  int runningTasks = 0;
  bool get loading => runningTasks > 0;
  bool showChangelog = false;
  LoginFormState loginFormState = LoginFormState.notShown;
  bool appLocked = false;
  late DateTime currentWeek;

  Campus campus = Campus.muelheim;
  Biometrics biometrics = Biometrics.OFF;
  TimetableView currentView = TimetableView.daily;
  TimetableView defaultView = TimetableView.daily;
  bool notificationsEnabled = false;
  bool enableConfirmRefreshDialog = true;
  String? lastUpdated;

  String? account;
  String? cnsc, args;
  Map<String, List<Event>> events = {};

  List<Module> modules = [];
  double gpa = 0;

  ThemeMode get effectiveTheme {
    if (activeTheme == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light;
    } else {
      return activeTheme;
    }
  }

  AppState() {
    currentWeek = DateTimeCalculator.getFirstDayOfWeek(
      DateTimeCalculator.clean(DateTime.now()),
    );

    if (DateTime.now().weekday >= 6) {
      currentWeek = currentWeek.add(const Duration(days: 7));
    }
  }
}
