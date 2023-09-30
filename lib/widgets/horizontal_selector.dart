import 'package:flutter/material.dart';

class HorizontalSelector<T> extends StatelessWidget {
  const HorizontalSelector({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
  });

  final Map<T, String> items;
  final void Function(T) onChanged;
  final T? value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            for (final item in items.entries)
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => onChanged(item.key),
                  child: Container(
                    decoration: BoxDecoration(
                      color: item.key == value
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      item.value,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
