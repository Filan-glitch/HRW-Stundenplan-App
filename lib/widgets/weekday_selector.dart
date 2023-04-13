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
          icon: const Icon(Icons.looks_one),
          title: const Text("Montag"),
          selectedColor: Theme.of(context).colorScheme.primary,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.looks_two),
          title: const Text("Dienstag"),
          selectedColor: Theme.of(context).colorScheme.primary,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.looks_3),
          title: const Text("Mittwoch"),
          selectedColor: Theme.of(context).colorScheme.primary,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.looks_4),
          title: const Text("Donnerstag"),
          selectedColor: Theme.of(context).colorScheme.primary,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.looks_5),
          title: const Text("Freitag"),
          selectedColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
}
