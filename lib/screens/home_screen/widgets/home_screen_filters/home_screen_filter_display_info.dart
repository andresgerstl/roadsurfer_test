import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadsurfer_test/providers/filter_provider.dart';
import 'package:roadsurfer_test/utils/extensions.dart';

class HomeScreenFilterDisplayInfo extends ConsumerWidget {
  const HomeScreenFilterDisplayInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth ~/ 300).clamp(2, 3);
        final showFilter = crossAxisCount == 3;
        if (showFilter) {
          return const SizedBox.shrink();
        }
        final filters = ref.watch(filterProvider);
        if (!filters.hasActiveFilters) {
          return const SizedBox.shrink();
        }
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: context.theme.primaryColor.withValues(alpha: .1),
          child: Row(
            children: [
              Icon(
                Icons.filter_list,
                color: context.theme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${filters.activeFilterCount} filter(s) applied',
                  style: TextStyle(
                    color: Colors.teal.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed:
                    () => ref.read(filterProvider.notifier).clearAllFilters(),
                child: const Text('Clear All'),
              ),
            ],
          ),
        );
      },
    );
  }
}
