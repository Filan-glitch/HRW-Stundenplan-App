/// List of actions, that are supported by the redux reducer function.
enum ActionTypes {
  setEvents,
  setGrades,
  setCampus,
  clear,
  setDesign,
  setCredentials,
  startTask,
  stopTask,
  setupCompleted,
  showChangelog,
  setLoginFormState,
  setCurrentWeek,
  setGPA,
  setLockState,
  setBiometricsType,
  setNotificationsEnabled,
  setView,
  setDefaultView,
  setAccount,
  setLastUpdated,
  setEnableConfirmRefreshDialog,
}

/// Representation of a redux action with its [type] and optional [payload].
class Action {
  ActionTypes type;
  dynamic payload;

  Action(this.type, {this.payload});
}
