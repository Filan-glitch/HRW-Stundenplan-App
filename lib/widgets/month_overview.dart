import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';

import '../login_page.dart';
import '../model/date_time_calculator.dart';
import '../model/timetable_view.dart';
import '../model/event.dart';
import '../model/redux/app_state.dart';
import '../model/redux/store.dart';
import '../model/redux/actions.dart' as redux;
import '../model/weekday.dart';
import '../service/db/events.dart';
import '../service/network_fetch.dart';

class MonthOverviewWidget extends StatelessWidget {
  const MonthOverviewWidget({required this.onSelectedDayChanged, super.key});

  final void Function(int dayOfWeek) onSelectedDayChanged;

  static const List<String> weekdays = ["Mo", "Di", "Mi", "Do", "Fr"];

  @override
  Widget build(BuildContext context) {
    DateFormat formatter = DateFormat('dd/MM/yyyy');

    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          DateTime firstDayOfMonth = DateTimeCalculator.getFirstDayOfWeek(
            DateTimeCalculator.getFirstDayOfMonth(
              DateTimeCalculator.clean(state.currentWeek),
            ),
          );

          List<DateTime> weeks = [
            firstDayOfMonth,
            firstDayOfMonth.add(const Duration(days: 7)),
            firstDayOfMonth.add(const Duration(days: 14)),
            firstDayOfMonth.add(const Duration(days: 21)),
            firstDayOfMonth.add(const Duration(days: 28)),
            firstDayOfMonth.add(const Duration(days: 35)),
          ]
              .where(
                (element) => element
                    .add(const Duration(days: 7))
                    .isAfter(DateTimeCalculator.clean(DateTime.now())),
              )
              .toList();

          return Container(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            child: Column(
              children: weeks.map((week) {
                if (!state.events.containsKey(formatter.format(week))) {
                  LoginPage.performLogin(onLoginSuccess: () async {
                    await loadWeekInterval(
                      start: state.currentWeek,
                      weeks: 6,
                    );
                    await writeDataToStorage();
                  });
                  return Container();
                }
                List<Event> eventsInWeek =
                    state.events[formatter.format(week)]!;
                bool isSelectedWeek =
                    DateTimeCalculator.isSameDay(week, state.currentWeek);

                return Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, i) {
                        DateTime date = week.add(Duration(days: i));
                        List<Event> eventsToday = eventsInWeek
                            .where(
                                (element) => element.day == Weekday.values[i])
                            .toList();
                        return Container(
                          constraints: BoxConstraints(
                            minWidth:
                                (MediaQuery.of(context).size.width / 5) - 2,
                          ),
                          margin: const EdgeInsets.all(0.5),
                          color: Theme.of(context)
                              .colorScheme
                              .background
                              .withOpacity(isSelectedWeek ? 0.8 : 1.0),
                          child: GestureDetector(
                            onTap: () {
                              // update current week in store
                              store.dispatch(
                                redux.Action(
                                  redux.ActionTypes.setCurrentWeek,
                                  payload: week,
                                ),
                              );

                              // update selected day by callback
                              onSelectedDayChanged(i);

                              // update to day view
                              store.dispatch(
                                redux.Action(
                                  redux.ActionTypes.setView,
                                  payload: TimetableView.daily,
                                ),
                              );
                            },
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Text(
                                    "${weekdays[i]} (${date.day}.)",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  ...eventsToday.map(
                                    (event) => Text(event.abbreviation),
                                  ),
                                  if (eventsToday.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15.0),
                                      child: Icon(
                                        Icons.sunny,
                                        size: 30.0,
                                        color: Theme.of(context)
                                            .dividerColor
                                            .withOpacity(0.5),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                );
              }).toList(),
            ),
          );
        });
  }
}
