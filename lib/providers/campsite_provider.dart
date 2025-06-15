import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadsurfer_test/models/campsite.dart';
import 'package:roadsurfer_test/services/api_services.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final campsitesProvider = FutureProvider<List<Campsite>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.fetchCampsites();
});

final sortedCampsitesProvider = Provider<AsyncValue<List<Campsite>>>((ref) {
  final campsitesAsync = ref.watch(campsitesProvider);

  return campsitesAsync.when(
    data: (campsites) {
      final sorted = List<Campsite>.from(campsites)
        ..sort((a, b) => a.label.compareTo(b.label));
      return AsyncValue.data(sorted);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

final campsiteDetailProvider = FutureProvider.family<Campsite, String>((
  ref,
  String id,
) async {
  final campsites = await ref.watch(campsitesProvider.future);

  for (final campsite in campsites) {
    if (campsite.id == id) {
      return campsite;
    }
  }

  final apiService = ref.read(apiServiceProvider);
  return apiService.fetchCampsiteById(id);
});
