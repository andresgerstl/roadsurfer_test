import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadsurfer_test/models/campsite.dart';
import 'package:roadsurfer_test/providers/campsite_provider.dart';

class CampsiteFilters {
  final bool? isCloseToWater;
  final bool? isCampFireAllowed;
  final String? hostLanguage;
  final double? minPrice;
  final double? maxPrice;

  const CampsiteFilters({
    this.isCloseToWater,
    this.isCampFireAllowed,
    this.hostLanguage,
    this.minPrice,
    this.maxPrice,
  });

  CampsiteFilters copyWith({
    bool? isCloseToWater,
    bool? isCampFireAllowed,
    String? hostLanguage,
    double? minPrice,
    double? maxPrice,
    bool clearWater = false,
    bool clearFire = false,
    bool clearLanguage = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
  }) {
    return CampsiteFilters(
      isCloseToWater:
          clearWater ? null : (isCloseToWater ?? this.isCloseToWater),
      isCampFireAllowed:
          clearFire ? null : (isCampFireAllowed ?? this.isCampFireAllowed),
      hostLanguage: clearLanguage ? null : (hostLanguage ?? this.hostLanguage),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
    );
  }

  bool get hasActiveFilters {
    return isCloseToWater != null ||
        isCampFireAllowed != null ||
        hostLanguage != null ||
        minPrice != null ||
        maxPrice != null;
  }

  int get activeFilterCount {
    int count = 0;
    if (isCloseToWater != null) count++;
    if (isCampFireAllowed != null) count++;
    if (hostLanguage != null) count++;
    if (minPrice != null) count++;
    if (maxPrice != null) count++;
    return count;
  }
}

class FilterNotifier extends StateNotifier<CampsiteFilters> {
  FilterNotifier() : super(const CampsiteFilters());

  void updateFilters(CampsiteFilters newFilters) {
    state = newFilters;
  }

  void clearAllFilters() {
    state = const CampsiteFilters();
  }

  void setWaterFilter(bool? value) {
    state = state.copyWith(isCloseToWater: value, clearWater: value == null);
  }

  void setFireFilter(bool? value) {
    state = state.copyWith(isCampFireAllowed: value, clearFire: value == null);
  }

  void setLanguageFilter(String? value) {
    state = state.copyWith(hostLanguage: value, clearLanguage: value == null);
  }

  void setPriceRange(double? min, double? max) {
    state = state.copyWith(
      minPrice: min,
      maxPrice: max,
      clearMinPrice: min == null,
      clearMaxPrice: max == null,
    );
  }
}

final filterProvider = StateNotifierProvider<FilterNotifier, CampsiteFilters>(
  (ref) => FilterNotifier(),
);

final filteredCampsitesProvider = Provider<AsyncValue<List<Campsite>>>((ref) {
  final campsitesAsync = ref.watch(sortedCampsitesProvider);
  final filters = ref.watch(filterProvider);

  return campsitesAsync.when(
    data: (campsites) {
      if (!filters.hasActiveFilters) {
        return AsyncValue.data(campsites);
      }

      final filtered =
          campsites.where((campsite) {
            if (filters.isCloseToWater != null &&
                campsite.isCloseToWater != filters.isCloseToWater) {
              return false;
            }
            if (filters.isCampFireAllowed != null &&
                campsite.isCampFireAllowed != filters.isCampFireAllowed) {
              return false;
            }
            if (filters.hostLanguage != null &&
                !campsite.hostLanguages.contains(
                  filters.hostLanguage!.toLowerCase(),
                )) {
              return false;
            }
            final priceInEuros = campsite.pricePerNight;
            if (filters.minPrice != null && priceInEuros < filters.minPrice!) {
              return false;
            }
            if (filters.maxPrice != null && priceInEuros > filters.maxPrice!) {
              return false;
            }
            return true;
          }).toList();

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});
