import 'app_state.dart';
import 'package:redux/redux.dart';

import 'reducer.dart';

/// Redux store.
final Store<AppState> store = Store<AppState>(
  appReducer,
  initialState: AppState(),
);
