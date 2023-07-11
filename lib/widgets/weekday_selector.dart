import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../model/weekday.dart';

class WeekdaySelectorWidget extends StatelessWidget {
  const WeekdaySelectorWidget(
      {required this.weekday, required this.onChanged, super.key});

  final Weekday weekday;
  final void Function(Weekday weekday) onChanged;

  @override
  Widget build(BuildContext context) {
    return SalomonBottomBar(
      currentIndex: weekday.value,
      onTap: (i) => onChanged(Weekday.getByValue(i)),
      items: [
        SalomonBottomBarItem(
          icon: Text(weekday == Weekday.monday ? "" : "Mo"),
          title: const Text("Montag"),
          selectedColor: Theme.of(context).colorScheme.primary,
        ),
        SalomonBottomBarItem(
          icon: Text(weekday == Weekday.tuesday ? "" : "Di"),
          title: const Text("Dienstag"),
          selectedColor: Theme.of(context).colorScheme.primary,
        ),
        SalomonBottomBarItem(
          icon: Text(weekday == Weekday.wednesday ? "" : "Mi"),
          title: const Text("Mittwoch"),
          selectedColor: Theme.of(context).colorScheme.primary,
        ),
        SalomonBottomBarItem(
          icon: Text(weekday == Weekday.thursday ? "" : "Do"),
          title: const Text("Donnerstag"),
          selectedColor: Theme.of(context).colorScheme.primary,
        ),
        SalomonBottomBarItem(
          icon: Text(weekday == Weekday.friday ? "" : "Fr"),
          title: const Text("Freitag"),
          selectedColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
}
