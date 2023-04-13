import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:timetable/service/network_fetch.dart';

import '../model/event.dart';
import '../model/redux/app_state.dart';
import '../service/storage.dart';
import 'break.dart';
import 'list_item.dart';

class TimetableWidget extends StatelessWidget {
  const TimetableWidget({
    required this.weekday,
    required this.startOfWeek,
    super.key,
  });

  final Weekday weekday;
  final DateTime startOfWeek;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        DateFormat formatter = DateFormat('dd/MM/yyyy');
        String key = formatter.format(startOfWeek);
        List<Event> events = [];

        DateTime currentMonday = DateTime.now().subtract(
          Duration(
            days: DateTime.now().weekday - 1,
          ),
        );

        bool isCurrentWeek = startOfWeek.day == currentMonday.day &&
            startOfWeek.month == currentMonday.month &&
            startOfWeek.year == currentMonday.year;

        if (state.events.containsKey(key)) {
          events = state.events[key]!
              .where((element) => element.day == weekday)
              .toList()
            ..sort();
        } else {
          loadFourWeekInterval(start: startOfWeek);
        }

        if (events.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                Icons.sunny,
                size: 120.0,
                color: Theme.of(context).dividerColor.withOpacity(0.5),
              ),
              const Text("Es stehen keine Termine an!"),
              TextButton(
                onPressed: () {
                  fetchData(startOfWeek).then((_) {
                    writeDataToStorage();
                  });
                },
                child: const Text("Aktualisieren"),
              ),
            ],
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await fetchData(startOfWeek).then((_) {
              writeDataToStorage();
            });
          },
          child: ListView.builder(
              itemCount: events.length,
              padding: const EdgeInsets.all(20),
              itemBuilder: (context, index) {
                // display break widget, if there is a time span longer than 15 minutes
                if (events.length > index + 1 &&
                    events[index + 1].start.totalMinutes -
                            events[index].end.totalMinutes >=
                        15) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListItem(
                        event: events[index],
                        currentWeek: isCurrentWeek,
                      ),
                      const BreakWidget()
                    ],
                  );
                } else {
                  return ListItem(
                    event: events[index],
                    currentWeek: isCurrentWeek,
                  );
                }
              }),
        );
      },
    );
  }
}
