import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:timetable/week_overview_page.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dialogs/info_dialog.dart';
import 'pdf_page.dart';
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
  double _swipeDeltaX = 0;

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
                if (state.updateAvailable)
                  IconButton(
                    onPressed: () {
                      launchUrl(
                        Uri.parse(
                            "https://www.janbellenberg.de/download/timetable.apk"),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                    icon: const Icon(
                      Icons.download,
                      color: Colors.white,
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
                          firstDayOfWeek: _currentWeek,
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
                          url:
                              "https://www.stw-edu.de/mensadaten/pdf/mensa-hrw-bottrop/aktuelle_woche.pdf",
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
                          url:
                              "https://www.stw-edu.de/mensadaten/pdf/mensa-hrw-bottrop/naechste_woche.pdf",
                        ),
                      ),
                    );
                  },
                ),
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
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onHorizontalDragStart: (details) => _swipeDeltaX = 0,
                      onHorizontalDragUpdate: (details) =>
                          _swipeDeltaX += details.delta.dx,
                      onHorizontalDragEnd: (details) {
                        // left swipe -> next page
                        if (_swipeDeltaX < -50) {
                          if (_activePage == Weekday.friday) {
                            setState(() {
                              _activePage = Weekday.monday;
                              _currentWeek = _currentWeek.add(
                                const Duration(days: 7),
                              );
                            });
                          } else {
                            setState(() {
                              _activePage =
                                  Weekday.getByValue(_activePage.value + 1);
                            });
                          }
                        } else if (_swipeDeltaX > 50) {
                          // right swipe -> previous page
                          if (_activePage == Weekday.monday &&
                              _currentWeek.isAfter(DateTime.now())) {
                            setState(() {
                              _activePage = Weekday.friday;
                              _currentWeek = _currentWeek.subtract(
                                const Duration(days: 7),
                              );
                            });
                          } else {
                            setState(() {
                              _activePage =
                                  Weekday.getByValue(_activePage.value - 1);
                            });
                          }
                        }
                      },
                      child: TimetableWidget(
                        weekday: _activePage,
                        startOfWeek: _currentWeek,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
