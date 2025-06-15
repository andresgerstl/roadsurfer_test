import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roadsurfer_test/providers/filter_provider.dart';

void main() {
  group('Filter Provider Tests', () {
    test('should start with empty filters', () {
      final container = ProviderContainer();
      final filters = container.read(filterProvider);

      expect(filters.hasActiveFilters, false);
      expect(filters.activeFilterCount, 0);
    });

    test('should update water filter', () {
      final container = ProviderContainer();
      final notifier = container.read(filterProvider.notifier);

      notifier.setWaterFilter(true);

      final filters = container.read(filterProvider);
      expect(filters.isCloseToWater, true);
      expect(filters.hasActiveFilters, true);
      expect(filters.activeFilterCount, 1);
    });

    test('should clear all filters', () {
      final container = ProviderContainer();
      final notifier = container.read(filterProvider.notifier);

      notifier.setWaterFilter(true);
      notifier.setFireFilter(false);
      notifier.clearAllFilters();

      final filters = container.read(filterProvider);
      expect(filters.hasActiveFilters, false);
      expect(filters.activeFilterCount, 0);
    });
  });
}
