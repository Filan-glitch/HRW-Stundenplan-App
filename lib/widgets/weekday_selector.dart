import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../model/event.dart';

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
          icon: weekday == Weekday.monday
              ? const Icon(Icons.looks_one)
              : const Text("Mo"),
          title: const Text("Montag"),
          selectedColor: Theme.of(context).colorScheme.primary,
        ),
        SalomonBottomBarItem(
          icon: weekday == Weekday.tuesday
              ? const Icon(Icons.looks_two)
              : const Text("Di"),
          title: const Text("Dienstag"),
          selectedColor: Theme.of(context).colorScheme.primary,
        ),
        SalomonBottomBarItem(
          icon: weekday == Weekday.wednesday
              ? const Icon(Icons.looks_3)
              : const Text("Mi"),
          title: const Text("Mittwoch"),
          selectedColor: Theme.of(context).colorScheme.primary,
        ),
        SalomonBottomBarItem(
          icon: weekday == Weekday.thursday
              ? const Icon(Icons.looks_4)
              : const Text("Do"),
          title: const Text("Donnerstag"),
          selectedColor: Theme.of(context).colorScheme.primary,
        ),
        SalomonBottomBarItem(
          icon: weekday == Weekday.friday
              ? const Icon(Icons.looks_5)
              : const Text("Fr"),
          title: const Text("Freitag"),
          selectedColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
}
