import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import 'dialogs/info_dialog.dart';
import 'edit_event_page.dart';
import 'loading_page.dart';
import 'model/redux/actions.dart' as redux;
import 'model/event.dart';
import 'model/redux/app_state.dart';
import 'model/redux/store.dart';
import 'welcome_page.dart';
import 'widgets/page_wrapper.dart';
import 'service/storage.dart';
import 'widgets/timetable.dart';
import 'widgets/week_selector.dart';
import 'widgets/weekday_selector.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Weekday _activePage = Weekday.monday;
  late DateTime _currentWeek;

  @override
  void initState() {
    super.initState();
    _currentWeek = DateTime.now().subtract(Duration(
      days: DateTime.now().weekday - 1,
    ));

    if (DateTime.now().weekday < 6) {
      _activePage = Weekday.getByValue(DateTime.now().weekday - 1);
    } else {
      _currentWeek = _currentWeek.add(const Duration(days: 7));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          if (state.loading) return const LoadingPage();
          if (state.args == null || state.cnsc == null) {
            return const WelcomePage();
          }

          return Scaffold(
            body: PageWrapper(
              actions: [
                /*ListTile(
                      leading: const Icon(
                        Icons.edit,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: state.editable
                          ? const Text("Änderungen speichern")
                          : const Text("Daten ändern"),
                      onTap: () {
                        Navigator.pop(context);
                        store.dispatch(
                          redux.Action(redux.ActionTypes.toggleEditMode),
                        );
                      },
                    ),*/
                ListTile(
                  leading: Icon(
                    Icons.lightbulb_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: state.darkmode
                      ? const Text("Helles Design")
                      : const Text("Dunkles Design"),
                  onTap: () {
                    store.dispatch(
                      redux.Action(
                        redux.ActionTypes.setDarkmode,
                        payload: !state.darkmode,
                      ),
                    );
                    writeDarkmodeToStorage();
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text("Abmelden"),
                  onTap: () {
                    Navigator.pop(context);
                    clearStorage();
                    store.dispatch(redux.Action(redux.ActionTypes.clear));
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text("Info"),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => const InfoDialog(),
                      barrierColor: Colors.transparent,
                    );
                  },
                ),
              ],
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: WeekSelectorWidget(
                      firstDayOfWeek: _currentWeek,
                      onHome: () {
                        setState(() {
                          _currentWeek = DateTime.now().subtract(Duration(
                            days: DateTime.now().weekday - 1,
                          ));

                          _activePage = Weekday.getByValue(
                            DateTime.now().weekday - 1,
                          );
                        });
                      },
                      onDateChanged: (week) {
                        setState(() {
                          _currentWeek = week;
                        });
                      },
                    ),
                  ),
                  Expanded(
                      child: TimetableWidget(
                    weekday: _activePage,
                    startOfWeek: _currentWeek,
                  )),
                ],
              ),
            ),
            floatingActionButton: state.editable
                ? FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditEventPage(),
                        ),
                      );
                    },
                    child: const Icon(Icons.add),
                  )
                : null,
            bottomNavigationBar: WeekdaySelectorWidget(
              weekday: _activePage,
              onChanged: (weekday) => setState(() {
                _activePage = weekday;
              }),
            ),
          );
        });
  }
}
