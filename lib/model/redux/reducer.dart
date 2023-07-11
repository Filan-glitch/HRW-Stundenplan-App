import '../campus.dart';
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
    state.currentWeek = action.payload;
  } else if (action.type == ActionTypes.setGrades) {
    state.modules = action.payload;
  } else if (action.type == ActionTypes.setGPA) {
    state.gpa = action.payload;
  } else if (action.type == ActionTypes.setCampus) {
    state.campus = action.payload;
  }
  return state;
}
