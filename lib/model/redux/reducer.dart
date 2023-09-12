import '../biometrics.dart';
import '../campus.dart';
import '../date_time_calculator.dart';
import '../timetable_view.dart';
import 'actions.dart';
import 'app_state.dart';

AppState appReducer(AppState state, dynamic action) {
  if (action is! Action) return state;

  if (action.type == ActionTypes.setEvents) {
    state.events[action.payload["date"]] = action.payload["events"];
  } else if (action.type == ActionTypes.clear) {
    state.darkmode = false;
    state.runningTasks = 0;
    state.cnsc = null;
    state.args = null;
    state.events = {};
    state.modules = [];
    state.gpa = 0;
    state.campus = Campus.muelheim;
    state.biometrics = Biometrics.OFF;
    state.currentView = TimetableView.daily;
    state.defaultView = TimetableView.daily;
    state.appLocked = false;
  } else if (action.type == ActionTypes.setDarkmode) {
    state.darkmode = action.payload;
  } else if (action.type == ActionTypes.setCredentials) {
    state.args = action.payload["args"];
    state.cnsc = action.payload["cnsc"];
  } else if (action.type == ActionTypes.startTask) {
    state.runningTasks++;
  } else if (action.type == ActionTypes.stopTask) {
    state.runningTasks--;
  } else if (action.type == ActionTypes.setupCompleted) {
    state.dataLoaded = true;
  } else if (action.type == ActionTypes.showChangelog) {
    state.showChangelog = action.payload;
  } else if (action.type == ActionTypes.setLoginFormState) {
    state.loginFormState = action.payload;
  } else if (action.type == ActionTypes.setCurrentWeek) {
    state.currentWeek = DateTimeCalculator.clean(action.payload);
  } else if (action.type == ActionTypes.setGrades) {
    state.modules = action.payload;
  } else if (action.type == ActionTypes.setGPA) {
    state.gpa = action.payload;
  } else if (action.type == ActionTypes.setCampus) {
    state.campus = action.payload;
  } else if (action.type == ActionTypes.setBiometricsType) {
    state.biometrics = action.payload;
  } else if (action.type == ActionTypes.setLockState) {
    state.appLocked = action.payload;
  } else if (action.type == ActionTypes.setNotificationsEnabled) {
    state.notificationsEnabled = action.payload;
  } else if (action.type == ActionTypes.setView) {
    state.currentView = action.payload;
  } else if (action.type == ActionTypes.setDefaultView) {
    state.defaultView = action.payload;
  }
  return state;
}
