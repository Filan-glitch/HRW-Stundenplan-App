import '../biometrics.dart';
import '../campus.dart';
import '../date_time_calculator.dart';
import '../timetable_view.dart';
import '../event.dart';
import '../login_state.dart';
import '../module.dart';

class AppState {
  bool darkmode = false;
  bool dataLoaded = false;
  int runningTasks = 0;
  bool get loading => runningTasks > 0;
  bool showChangelog = false;
  LoginFormState loginFormState = LoginFormState.notShown;
  Campus campus = Campus.muelheim;
  Biometrics biometrics = Biometrics.OFF;
  TimetableView currentView = TimetableView.daily;
  TimetableView defaultView = TimetableView.daily;
  bool appLocked = false;
  bool notificationsEnabled = false;

  String? cnsc, args;
  Map<String, List<Event>> events = {};
  late DateTime currentWeek;

  List<Module> modules = [];
  double gpa = 0;

  AppState() {
    currentWeek = DateTimeCalculator.getFirstDayOfWeek(
      DateTimeCalculator.clean(DateTime.now()),
    );

    if (DateTime.now().weekday >= 6) {
      currentWeek = currentWeek.add(const Duration(days: 7));
    }
  }
}
