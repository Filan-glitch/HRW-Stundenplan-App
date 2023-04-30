/// List of actions, that are supported by the redux reducer function.
enum ActionTypes {
  setEvents,
  clear,
  setDarkmode,
  setCredentials,
  startTask,
  stopTask,
  setupCompleted,
  updateAvailable,
}

/// Representation of a redux action with its [type] and optional [payload].
class Action {
  ActionTypes type;
  dynamic payload;

  Action(this.type, {this.payload});
}
