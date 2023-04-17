import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:timetable/widgets/empty_schedule.dart';

import 'model/event.dart';
import 'model/redux/app_state.dart';
import 'widgets/list_item.dart';

class WeekOverviewPage extends StatelessWidget {
  WeekOverviewPage({required this.firstDayOfWeek, super.key});

  final DateTime firstDayOfWeek;
  final DateFormat titleFormatter = DateFormat('dd.MM.yyyy');
  final DateFormat formatter = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    DateTime lastDay = firstDayOfWeek.add(const Duration(days: 6));
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${titleFormatter.format(firstDayOfWeek)} - ${titleFormatter.format(lastDay)}"),
      ),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Column(
          children: [
            for (Weekday day in Weekday.values)
              StoreConnector<AppState, AppState>(
                converter: (store) => store.state,
                builder: (context, state) {
                  String key = formatter.format(firstDayOfWeek);
                  if (!state.events.containsKey(key)) return Container();
                  List<Event> events = [];
                  events = state.events[key]!
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
                              color: Theme.of(context).colorScheme.primary,
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
                            return ListItem(
                              currentWeek: false,
                              event: events[index],
                            );
                          },
                        )
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
