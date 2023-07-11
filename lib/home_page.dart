import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:timetable/grades_overview_page.dart';
import 'package:timetable/week_overview_page.dart';

import 'dialogs/changelog_dialog.dart';
import 'model/campus.dart';
import 'model/constants.dart';
import 'model/redux/actions.dart' as redux;
import 'model/redux/store.dart';
import 'model/weekday.dart';
import 'pdf_page.dart';
import 'model/redux/app_state.dart';
import 'settings_page.dart';
import 'widgets/page_wrapper.dart';
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
  double _swipeDeltaX = 0;

  @override
  void initState() {
    super.initState();

    DateTime currentWeek = DateTime.now().subtract(Duration(
      days: DateTime.now().weekday - 1,
    ));

    if (DateTime.now().weekday < 6) {
      _activePage = Weekday.getByValue(DateTime.now().weekday - 1);
    } else {
      currentWeek = currentWeek.add(const Duration(days: 7));
    }

    store.dispatch(redux.Action(
      redux.ActionTypes.setCurrentWeek,
      payload: currentWeek,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return PageWrapper(
            bottomNavigationBar: WeekdaySelectorWidget(
              weekday: _activePage,
              onChanged: (weekday) => setState(() {
                _activePage = weekday;
              }),
            ),
            actions: [
              if (state.showChangelog)
                IconButton(
                  onPressed: () {
                    store.dispatch(redux.Action(
                      redux.ActionTypes.showChangelog,
                      payload: false,
                    ));

                    showDialog(
                      context: context,
                      builder: (context) => ChangelogDialog(),
                    );
                  },
                  icon: Badge(
                    backgroundColor: Colors.red.withOpacity(0.9),
                    label: const Text('1'),
                    child: const Icon(
                      Icons.update,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
            menuActions: [
              ListTile(
                leading: Icon(
                  Icons.calendar_month,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text("Wochenübersicht"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeekOverviewPage(
                        firstDayOfWeek: state.currentWeek,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.fastfood,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text("Speiseplan"),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PdfPage(
                        title: "Speiseplan",
                        url: state.campus == Campus.bottrop
                            ? MENSA_BOT_CURRENT_URL
                            : MENSA_MUE_CURRENT_URL,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.fastfood,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text("Speiseplan (nächste Woche)"),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PdfPage(
                        title: "Speiseplan",
                        url: state.campus == Campus.bottrop
                            ? MENSA_BOT_NEXT_URL
                            : MENSA_MUE_NEXT_URL,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                  leading: Icon(
                    Icons.assessment,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text("Prüfungsergebnisse"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GradesOverviewPage(),
                        ));
                  }),
              ListTile(
                leading: Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text("Einstellungen"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  );
                },
              ),
            ],
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: WeekSelectorWidget(
                    firstDayOfWeek: state.currentWeek,
                    onHome: () {
                      store.dispatch(redux.Action(
                        redux.ActionTypes.setCurrentWeek,
                        payload: DateTime.now().subtract(
                          Duration(
                            days: DateTime.now().weekday - 1,
                          ),
                        ),
                      ));

                      setState(() {
                        _activePage = Weekday.getByValue(
                          DateTime.now().weekday - 1,
                        );
                      });
                    },
                    onDateChanged: (week) {
                      store.dispatch(redux.Action(
                        redux.ActionTypes.setCurrentWeek,
                        payload: week,
                      ));
                    },
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragStart: (details) => _swipeDeltaX = 0,
                    onHorizontalDragUpdate: (details) =>
                        _swipeDeltaX += details.delta.dx,
                    onHorizontalDragEnd: (details) {
                      if (_swipeDeltaX < -50) {
                        // left swipe -> next page
                        nextDay();
                      } else if (_swipeDeltaX > 50) {
                        // right swipe -> previous page
                        previousDay();
                      }
                    },
                    child: TimetableWidget(
                      weekday: _activePage,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void nextDay() {
    if (_activePage == Weekday.friday) {
      store.dispatch(redux.Action(
        redux.ActionTypes.setCurrentWeek,
        payload: store.state.currentWeek.add(
          const Duration(days: 7),
        ),
      ));

      setState(() {
        _activePage = Weekday.monday;
      });
    } else {
      setState(() {
        _activePage = Weekday.getByValue(_activePage.value + 1);
      });
    }
  }

  void previousDay() {
    if (_activePage == Weekday.monday &&
        store.state.currentWeek.isAfter(DateTime.now())) {
      store.dispatch(redux.Action(
        redux.ActionTypes.setCurrentWeek,
        payload: store.state.currentWeek.subtract(
          const Duration(days: 7),
        ),
      ));

      setState(() {
        _activePage = Weekday.friday;
      });
    } else {
      setState(() {
        _activePage = Weekday.getByValue(_activePage.value - 1);
      });
    }
  }
}
