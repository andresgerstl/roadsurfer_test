import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadsurfer_test/providers/campsite_provider.dart';
import 'package:roadsurfer_test/providers/filter_provider.dart';
import 'package:roadsurfer_test/screens/home_screen/widgets/home_screen_filters/filter_state_picker.dart';
import 'package:roadsurfer_test/utils/app_theme.dart';
import 'package:roadsurfer_test/utils/extensions.dart';

class HomeScreenGridFilter extends ConsumerStatefulWidget {
  const HomeScreenGridFilter({super.key});

  @override
  ConsumerState<HomeScreenGridFilter> createState() =>
      _HomeScreenGridFilterState();
}

class _HomeScreenGridFilterState extends ConsumerState<HomeScreenGridFilter> {
  RangeValues? priceRange;
  double maxPrice = 1000.0;

  @override
  void initState() {
    super.initState();
    final filters = ref.read(filterProvider);
    if (filters.minPrice != null || filters.maxPrice != null) {
      priceRange = RangeValues(
        filters.minPrice ?? 0,
        filters.maxPrice ?? maxPrice,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final campsitesAsync = ref.watch(sortedCampsitesProvider);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Campsites filters',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
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
                  Text(
                    'Close to water',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  FilterStatePicker(
                    currentValue: ref.watch(filterProvider).isCloseToWater,
                    onChanged:
                        (value) => setState(() {
                          ref
                              .read(filterProvider.notifier)
                              .setWaterFilter(value);
                        }),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Campfire',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FilterStatePicker(
                    currentValue: ref.watch(filterProvider).isCampFireAllowed,
                    onChanged:
                        (value) => setState(() {
                          ref
                              .read(filterProvider.notifier)
                              .setFireFilter(value);
                        }),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Host language',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                            selected:
                                ref.watch(filterProvider).hostLanguage == null,
                            onSelected:
                                (selected) => ref
                                    .read(filterProvider.notifier)
                                    .setLanguageFilter(null),
                          ),
                          ...languages.map(
                            (lang) => FilterChip(
                              label: Text(lang.toUpperCase()),
                              selected:
                                  ref.watch(filterProvider).hostLanguage ==
                                  lang,
                              onSelected:
                                  (selected) => ref
                                      .read(filterProvider.notifier)
                                      .setLanguageFilter(lang),
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Text('Error loading languages'),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Price range (per night)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                                  ref
                                      .read(filterProvider.notifier)
                                      .setPriceRange(
                                        priceRange!.start,
                                        priceRange!.end,
                                      );
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
                  const SizedBox(height: 64),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          priceRange = null;
                          ref.read(filterProvider.notifier).clearAllFilters();
                        });
                      },
                      child: const Text('Clear All'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
