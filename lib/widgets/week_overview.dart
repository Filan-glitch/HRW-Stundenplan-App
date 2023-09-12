import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';

import '../model/event.dart';
import '../model/redux/app_state.dart';
import '../model/weekday.dart';
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
    DateFormat formatter = DateFormat('dd/MM/yyyy');
    return SingleChildScrollView(
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
    );
  }
}
