import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';

import '../model/event.dart';
import '../model/redux/app_state.dart';
import '../model/redux/store.dart';
import '../model/weekday.dart';
import '../pages/login_page.dart';
import '../service/db/events.dart';
import '../service/network_fetch.dart';
import 'break.dart';
import 'empty_schedule.dart';
import 'list_item.dart';

class WeekOverview extends StatelessWidget {
  const WeekOverview({
    super.key,
    required this.firstDayOfWeek,
  });

  final DateTime firstDayOfWeek;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return StoreConnector<AppState, AppState>(
          converter: (store) => store.state,
          builder: (context, state) {
            DateFormat formatter = DateFormat('dd/MM/yyyy');
            String key = formatter.format(state.currentWeek);

            if (!state.events.containsKey(key)) {
              LoginPage.performLogin(onLoginSuccess: () async {
                await loadWeekInterval(
                  start: store.state.currentWeek,
                );
                await writeDataToStorage();
              });

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: const EmptyScheduleWidget(),
                ),
              );
            }

            return SingleChildScrollView(
              physics: const ScrollPhysics(),
              child: Column(
                children: [
                  for (Weekday day in Weekday.values)
                    Builder(
                      builder: (context) {
                        List<Event> events = state.events[key]!
                            .where((element) => element.day == day)
                            .toList()
                          ..sort();

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 10.0,
                          ),
                          child: Column(
                            children: [
                              Text(
                                day.text,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 20.0),
                              ),
                              if (events.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(top: 15.0),
                                  child: EmptyScheduleWidget(sunSize: 70.0),
                                ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: events.length,
                                itemBuilder: (context, index) {
                                  // display break widget, if there is a time span longer than 15 minutes
                                  if (events.length > index + 1 &&
                                      events[index + 1].start.totalMinutes -
                                              events[index].end.totalMinutes >=
                                          15) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ListItem(
                                          event: events[index],
                                        ),
                                        const BreakWidget()
                                      ],
                                    );
                                  } else {
                                    return ListItem(
                                      event: events[index],
                                    );
                                  }
                                },
                              )
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
