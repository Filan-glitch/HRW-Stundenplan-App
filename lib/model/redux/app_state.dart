import '../event.dart';

class AppState {
  bool darkmode = false;
  bool editable = false;
  bool dataLoaded = false;
  int runningTasks = 0;
  bool get loading => runningTasks > 0;
  String? cnsc, args;
  Map<String, List<Event>> events = {};
}
