import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:roadsurfer_test/providers/campsite_provider.dart';
import 'package:roadsurfer_test/providers/filter_provider.dart';
import 'package:roadsurfer_test/utils/app_theme.dart';
import 'package:roadsurfer_test/utils/extensions.dart';

class HomeScreenFilterSheet extends ConsumerStatefulWidget {
  const HomeScreenFilterSheet({super.key});

  @override
  ConsumerState<HomeScreenFilterSheet> createState() =>
      _HomeScreenFilterSheetState();
}

class _HomeScreenFilterSheetState extends ConsumerState<HomeScreenFilterSheet> {
  late CampsiteFilters localFilters;
  RangeValues? priceRange;
  double maxPrice = 1000.0;

  @override
  void initState() {
    super.initState();
    localFilters = ref.read(filterProvider);
    if (localFilters.minPrice != null || localFilters.maxPrice != null) {
      priceRange = RangeValues(
        localFilters.minPrice ?? 0,
        localFilters.maxPrice ?? maxPrice,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final campsitesAsync = ref.watch(sortedCampsitesProvider);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Filter Campsites',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      localFilters = const CampsiteFilters();
                      priceRange = null;
                    });
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: horizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Close to water'),
                  _buildTriStateFilter(
                    'Close to water',
                    localFilters.isCloseToWater,
                    (value) => setState(() {
                      localFilters = localFilters.copyWith(
                        isCloseToWater: value,
                        clearWater: value == null,
                      );
                    }),
                  ),

                  const SizedBox(height: 24),

                  // Campfire Filter
                  _buildSectionTitle('Campfire'),
                  _buildTriStateFilter(
                    'Campfire Allowed',
                    localFilters.isCampFireAllowed,
                    (value) => setState(() {
                      localFilters = localFilters.copyWith(
                        isCampFireAllowed: value,
                        clearFire: value == null,
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  // Language Filter
                  _buildSectionTitle('Host Language'),
                  campsitesAsync.when(
                    data: (campsites) {
                      final languages = <String>{};
                      for (final campsite in campsites) {
                        languages.addAll(campsite.hostLanguages);
                      }

                      return Wrap(
                        spacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('Any'),
                            selected: localFilters.hostLanguage == null,
                            onSelected:
                                (selected) => setState(() {
                                  localFilters = localFilters.copyWith(
                                    clearLanguage: true,
                                  );
                                }),
                          ),
                          ...languages.map(
                            (lang) => FilterChip(
                              label: Text(lang.toUpperCase()),
                              selected: localFilters.hostLanguage == lang,
                              onSelected:
                                  (selected) => setState(() {
                                    localFilters = localFilters.copyWith(
                                      hostLanguage: selected ? lang : null,
                                      clearLanguage: !selected,
                                    );
                                  }),
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Text('Error loading languages'),
                  ),

                  const SizedBox(height: 24),

                  // Price Range Filter
                  _buildSectionTitle('Price Range (per night)'),
                  campsitesAsync.when(
                    data: (campsites) {
                      if (campsites.isEmpty) return const SizedBox();

                      final prices =
                          campsites.map((c) => c.pricePerNight).toList()
                            ..sort();

                      final minPrice = prices.first;
                      final maxPriceData = prices.last;

                      return Column(
                        children: [
                          RangeSlider(
                            values:
                                priceRange ??
                                RangeValues(minPrice, maxPriceData),
                            min: minPrice,
                            max: maxPriceData,
                            divisions: 20,
                            labels: RangeLabels(
                              (priceRange?.start ?? minPrice).formattedPrice(),
                              (priceRange?.end ?? maxPriceData)
                                  .formattedPrice(),
                            ),
                            onChanged:
                                (values) => setState(() {
                                  priceRange = values;
                                }),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(minPrice.formattedPrice()),
                              Text(maxPriceData.formattedPrice()),
                            ],
                          ),
                          if (priceRange != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Selected: ${priceRange!.start.formattedPrice()} - ${priceRange!.end.formattedPrice()}',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Text('Error loading price range'),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (priceRange != null) {
                    localFilters = localFilters.copyWith(
                      minPrice: priceRange!.start,
                      maxPrice: priceRange!.end,
                    );
                  } else {
                    localFilters = localFilters.copyWith(
                      clearMinPrice: true,
                      clearMaxPrice: true,
                    );
                  }
                  ref.read(filterProvider.notifier).updateFilters(localFilters);
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTriStateFilter(
    String label,
    bool? currentValue,
    ValueChanged<bool?> onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<bool?>(
            title: const Text('Any'),
            value: null,
            groupValue: currentValue,
            onChanged: onChanged,
            dense: true,
          ),
        ),
        Expanded(
          child: RadioListTile<bool?>(
            title: const Text('Yes'),
            value: true,
            groupValue: currentValue,
            onChanged: onChanged,
            dense: true,
          ),
        ),
        Expanded(
          child: RadioListTile<bool?>(
            title: const Text('No'),
            value: false,
            groupValue: currentValue,
            onChanged: onChanged,
            dense: true,
          ),
        ),
      ],
    );
  }
}
