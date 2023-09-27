import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';

import '../model/date_time_calculator.dart';
import '../model/event.dart';
import '../model/redux/actions.dart' as redux;
import '../model/redux/app_state.dart';
import '../model/redux/store.dart';
import '../model/timetable_view.dart';
import '../model/weekday.dart';
import '../pages/login_page.dart';
import '../service/db/events.dart';
import '../service/network_fetch.dart';

class MonthOverviewWidget extends StatelessWidget {
  const MonthOverviewWidget({required this.onSelectedDayChanged, super.key});

  final void Function(int dayOfWeek) onSelectedDayChanged;

  static const List<String> weekdays = ["Mo", "Di", "Mi", "Do", "Fr"];

  @override
  Widget build(BuildContext context) {
    DateFormat formatter = DateFormat('dd/MM/yyyy');

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: constraints.maxHeight,
            child: StoreConnector<AppState, AppState>(
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
                  //color: Theme.of(context).dividerColor.withOpacity(0.5),
                  margin: const EdgeInsets.only(top: 10.0),
                  child: Column(
                    children: weeks.map<Widget>((week) {
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
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: 5,
                              itemBuilder: (context, i) {
                                DateTime date = week.add(Duration(days: i));
                                List<Event> eventsToday = eventsInWeek
                                    .where((element) =>
                                        element.day == Weekday.values[i])
                                    .toList();
                                return Container(
                                  constraints: BoxConstraints(
                                    minWidth:
                                        (MediaQuery.of(context).size.width /
                                                5) -
                                            2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                  ),
                                  color: Color.lerp(
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.background,
                                    isSelectedWeek ? 0.9 : 1,
                                  ),
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
                                            "${weekdays[i]}. ${date.day}.${date.month}.",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          ...eventsToday.map(
                                            (event) => Text(event.abbreviation),
                                          ),
                                          if (eventsToday.isEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 15.0),
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
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
