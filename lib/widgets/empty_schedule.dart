import 'package:flutter/material.dart';

class EmptyScheduleWidget extends StatelessWidget {
  const EmptyScheduleWidget({
    super.key,
    this.onRefresh,
    this.sunSize = 120.0,
  });

  final double sunSize;
  final void Function()? onRefresh;

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
        if (onRefresh != null)
          TextButton(
            onPressed: onRefresh!,
            child: const Text("Aktualisieren"),
          ),
      ],
    );
  }
}
