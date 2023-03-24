import 'package:flutter/material.dart';

import 'model/event.dart';

class ListItem extends StatelessWidget {
  const ListItem({required this.event, this.currentWeekday = false, super.key});

  final Event event;
  final bool currentWeekday;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: event.getMode() == Mode.done && currentWeekday ? 0.6 : 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: event.getMode() == Mode.active && currentWeekday
                ? const BorderSide(
                    color: Colors.blue,
                    width: 5,
                  )
                : BorderSide.none,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.module,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                event.eventType,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('${event.startTime} - ${event.endTime}    ${event.room}'),
            ],
          ),
        ),
      ),
    );
  }
}
