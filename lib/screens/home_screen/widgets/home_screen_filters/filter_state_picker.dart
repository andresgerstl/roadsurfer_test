import 'package:flutter/material.dart';

class FilterStatePicker extends StatelessWidget {
  const FilterStatePicker({
    required this.currentValue,
    required this.onChanged,
    super.key,
  });
  final bool? currentValue;
  final ValueChanged<bool?> onChanged;
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          onSelected: (_) => onChanged(null),
          selected: currentValue == null,
          label: const Text('Any'),
        ),
        FilterChip(
          onSelected: (_) => onChanged(true),
          selected: currentValue == true,
          label: const Text('Yes'),
        ),
        FilterChip(
          onSelected: (_) => onChanged(false),
          selected: currentValue == false,
          label: const Text('No'),
        ),
      ],
    );
  }
}
