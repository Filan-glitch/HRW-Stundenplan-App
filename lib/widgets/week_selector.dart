import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeekSelectorWidget extends StatelessWidget {
  WeekSelectorWidget(
      {required this.firstDayOfWeek,
      required this.onDateChanged,
      required this.onHome,
      super.key});

  final DateTime firstDayOfWeek;
  final void Function(DateTime week) onDateChanged;
  final void Function() onHome;

  final DateFormat formatter = DateFormat('dd.MM.yyyy');

  int calculateWeekNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    final weekNumber = ((dayOfYear - date.weekday + 10) / 7).floor();
    return weekNumber;
  }

  @override
  Widget build(BuildContext context) {
    DateTime lastDay = firstDayOfWeek.add(const Duration(days: 6));
    int weekNumber = calculateWeekNumber(firstDayOfWeek);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: firstDayOfWeek.isBefore(DateTime.now())
              ? null
              : () {
                  onDateChanged(
                      firstDayOfWeek.subtract(const Duration(days: 7)));
                },
          icon: const Icon(Icons.arrow_back),
        ),
        TextButton(
          onPressed: onHome,
          child: Text(
            "${formatter.format(firstDayOfWeek)} - ${formatter.format(lastDay)}\nKW $weekNumber",
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          onPressed: () {
            onDateChanged(firstDayOfWeek.add(const Duration(days: 7)));
          },
          icon: const Icon(Icons.arrow_forward),
        ),
      ],
    );
  }
}
