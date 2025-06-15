import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadsurfer_test/providers/filter_provider.dart';
import 'package:roadsurfer_test/screens/home_screen/widgets/home_screen_filters/home_screen_filter_sheet.dart';

class HomeScreenFilterButton extends ConsumerWidget {
  const HomeScreenFilterButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(filterProvider);

    return Stack(
      children: [
        IconButton(
          onPressed: () => _showFilterBottomSheet(context),
          icon: const Icon(Icons.filter_list),
        ),
        if (filters.hasActiveFilters)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                filters.activeFilterCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const HomeScreenFilterSheet(),
    );
  }
}
