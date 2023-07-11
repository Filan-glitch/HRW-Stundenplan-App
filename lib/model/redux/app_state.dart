import '../campus.dart';
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

  String? cnsc, args;
  Map<String, List<Event>> events = {};
  late DateTime currentWeek;

  List<Module> modules = [];
  double gpa = 0;

  AppState() {
    currentWeek = DateTime.now().subtract(Duration(
      days: DateTime.now().weekday - 1,
    ));

    if (DateTime.now().weekday >= 6) {
      currentWeek = currentWeek.add(const Duration(days: 7));
    }
  }
}
