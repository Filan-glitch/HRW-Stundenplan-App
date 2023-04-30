import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../model/event.dart';
import '../model/redux/app_state.dart';

class ListItem extends StatelessWidget {
  const ListItem({required this.event, required this.currentWeek, super.key});

  final Event event;
  final bool currentWeek;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return Opacity(
            opacity: event.mode == Mode.done && currentWeek ? 0.6 : 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: event.mode == Mode.active && currentWeek
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
                  horizontal:
                      event.mode == Mode.active && currentWeek ? 10.0 : 0.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${event.start} - ${event.end}'),
                            Text(event.room),
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
