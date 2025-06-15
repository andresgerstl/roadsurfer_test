import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:roadsurfer_test/models/campsite.dart';
import 'package:roadsurfer_test/providers/campsite_provider.dart';

@immutable
class MapCluster {
  final LatLng position;
  final List<Campsite> campsites;
  final bool isCluster;

  const MapCluster({
    required this.position,
    required this.campsites,
    required this.isCluster,
  });

  int get count => campsites.length;

  Campsite get firstCampsite => campsites.first;
}

@immutable
class MapState {
  final List<MapCluster> clusters;
  final double currentZoom;
  final LatLng? center;
  final bool isLoading;
  final String? error;

  const MapState({
    required this.clusters,
    required this.currentZoom,
    this.center,
    this.isLoading = false,
    this.error,
  });

  MapState copyWith({
    List<MapCluster>? clusters,
    double? currentZoom,
    LatLng? center,
    bool? isLoading,
    String? error,
  }) {
    return MapState(
      clusters: clusters ?? this.clusters,
      currentZoom: currentZoom ?? this.currentZoom,
      center: center ?? this.center,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class MapClusteringNotifier extends StateNotifier<MapState> {
  MapClusteringNotifier()
    : super(const MapState(clusters: [], currentZoom: 10.0));

  static const double _minZoomForClustering = 13.0;

  void updateClusters(List<Campsite> campsites, double zoom) {
    state = state.copyWith(currentZoom: zoom);

    if (campsites.isEmpty) {
      state = state.copyWith(clusters: []);
      return;
    }
    final center = _calculateCenter(campsites);

    List<MapCluster> clusters = _performDynamicClustering(campsites, zoom);

    state = state.copyWith(
      clusters: clusters,
      center: center,
      isLoading: false,
      error: null,
    );
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  LatLng _calculateCenter(List<Campsite> campsites) {
    double totalLat = 0;
    double totalLng = 0;

    for (final campsite in campsites) {
      totalLat += campsite.geoLocation.lat;
      totalLng += campsite.geoLocation.long;
    }

    return LatLng(totalLat / campsites.length, totalLng / campsites.length);
  }

  List<MapCluster> _performDynamicClustering(
    List<Campsite> campsites,
    double zoom,
  ) {
    final double gridSize = _calculateGridSize(zoom);

    final Map<String, List<Campsite>> gridClusters = {};

    for (final campsite in campsites) {
      final gridKey = _getGridKey(
        campsite.geoLocation.lat,
        campsite.geoLocation.long,
        gridSize,
      );

      gridClusters.putIfAbsent(gridKey, () => []);
      gridClusters[gridKey]!.add(campsite);
    }

    final List<MapCluster> clusters = [];

    for (final campsiteGroup in gridClusters.values) {
      if (campsiteGroup.isEmpty) continue;

      if (zoom >= _minZoomForClustering && campsiteGroup.length == 1) {
        clusters.add(
          MapCluster(
            position: LatLng(
              campsiteGroup.first.geoLocation.lat,
              campsiteGroup.first.geoLocation.long,
            ),
            campsites: campsiteGroup,
            isCluster: false,
          ),
        );
      } else {
        final LatLng clusterCenter = _calculateClusterCenter(campsiteGroup);
        clusters.add(
          MapCluster(
            position: clusterCenter,
            campsites: campsiteGroup,
            isCluster: campsiteGroup.length > 1,
          ),
        );
      }
    }

    return clusters;
  }

  double _calculateGridSize(double zoom) {
    if (zoom <= 3) return 10.0;
    if (zoom <= 5) return 1.0;
    if (zoom <= 7) return .5;
    if (zoom <= 9) return .3;
    if (zoom <= 10) return .2;
    if (zoom <= 13) return 0.1;
    return 0.1;
  }

  String _getGridKey(double lat, double lng, double gridSize) {
    final int latGrid = (lat / gridSize).floor();
    final int lngGrid = (lng / gridSize).floor();
    return '$latGrid,$lngGrid';
  }

  LatLng _calculateClusterCenter(List<Campsite> campsites) {
    double totalLat = 0;
    double totalLng = 0;

    for (final campsite in campsites) {
      totalLat += campsite.geoLocation.lat;
      totalLng += campsite.geoLocation.long;
    }

    return LatLng(totalLat / campsites.length, totalLng / campsites.length);
  }
}

final mapClusteringProvider =
    StateNotifierProvider<MapClusteringNotifier, MapState>((ref) {
      return MapClusteringNotifier();
    });

final mapClustersProvider = Provider<AsyncValue<List<MapCluster>>>((ref) {
  final campsitesAsync = ref.watch(sortedCampsitesProvider);
  final mapState = ref.watch(mapClusteringProvider);

  return campsitesAsync.when(
    data: (campsites) {
      if (campsites.isEmpty) {
        return const AsyncValue.data([]);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(mapClusteringProvider.notifier)
            .updateClusters(campsites, mapState.currentZoom);
      });
      return AsyncValue.data(mapState.clusters);
    },
    loading: () {
      ref.read(mapClusteringProvider.notifier).setLoading(true);
      return const AsyncValue.loading();
    },
    error: (error, stack) {
      ref.read(mapClusteringProvider.notifier).setError(error.toString());
      return AsyncValue.error(error, stack);
    },
  );
});
