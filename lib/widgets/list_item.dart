import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../model/event.dart';
import '../model/mode.dart';
import '../model/redux/app_state.dart';

class ListItem extends StatefulWidget {
  const ListItem({required this.event, super.key});

  final Event event;

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  late final Timer _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          DateTime currentMonday = DateTime.now().subtract(
            Duration(
              days: DateTime.now().weekday - 1,
            ),
          );

          bool isCurrentWeek = state.currentWeek.day == currentMonday.day &&
              state.currentWeek.month == currentMonday.month &&
              state.currentWeek.year == currentMonday.year;

          DateTime now = DateTime.now();
          DateTime start = DateTime(
            state.currentWeek.year,
            state.currentWeek.month,
            state.currentWeek.day + widget.event.day.value,
            widget.event.start.hour,
            widget.event.start.minute,
          );

          DateTime end = DateTime(
            state.currentWeek.year,
            state.currentWeek.month,
            state.currentWeek.day + widget.event.day.value,
            widget.event.end.hour,
            widget.event.end.minute,
          );

          Widget? timeIndicatorWidget;
          if (now.isBefore(start) && start.difference(now).inMinutes <= 90) {
            timeIndicatorWidget = Text(
              "Beginnt in ${start.difference(now).inMinutes} Minuten",
            );
          } else if (now.isBefore(end) && now.isAfter(start) ||
              now.isAtSameMomentAs(start)) {
            timeIndicatorWidget = Text(
              "Läuft noch ${end.difference(now).inMinutes} Minuten",
            );
          }

          return Opacity(
            opacity: widget.event.mode == Mode.done && isCurrentWeek ? 0.6 : 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: widget.event.mode == Mode.active && isCurrentWeek
                      ? BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 5,
                        )
                      : BorderSide.none,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: widget.event.mode == Mode.active && isCurrentWeek
                      ? 10.0
                      : 0.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${widget.event.start} - ${widget.event.end}'),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Text(widget.event.room),
                            ),
                            timeIndicatorWidget ?? Container(),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
