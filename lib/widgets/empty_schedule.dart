import 'package:flutter/material.dart';

class EmptyScheduleWidget extends StatelessWidget {
  const EmptyScheduleWidget({
    super.key,
    this.sunSize = 120.0,
  });

  final double sunSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Icon(
          Icons.sunny,
          size: sunSize,
          color: Theme.of(context).dividerColor.withOpacity(0.5),
        ),
        const Text("Es stehen keine Termine an!"),
      ],
    );
  }
}
