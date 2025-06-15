import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:roadsurfer_test/models/campsite.dart';
import 'package:roadsurfer_test/providers/campsite_provider.dart';
import 'package:roadsurfer_test/providers/map_provider.dart';
import 'package:roadsurfer_test/routing/routes.dart';
import 'package:roadsurfer_test/utils/app_icons.dart';
import 'package:roadsurfer_test/utils/extensions.dart';
import 'package:roadsurfer_test/widgets/loading_widget.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapController = MapController();
  static const _defaultCenter = LatLng(52.5200, 13.4050); // Berlin

  @override
  Widget build(BuildContext context) {
    final mapClustersAsync = ref.watch(mapClustersProvider);
    final mapState = ref.watch(mapClusteringProvider);

    return Scaffold(
      appBar: AppBar(
        title: SvgPicture.asset(
          AppIcons.roadsurferLogo,
          height: kToolbarHeight - 25,
        ),
        centerTitle: true,
      ),
      body: mapClustersAsync.when(
        data: (clusters) {
          if (clusters.isEmpty) {
            return const Center(child: LoadingWidget());
          }
          return _buildMap(clusters, mapState);
        },
        loading: () => const Center(child: LoadingWidget()),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildMap(List<MapCluster> clusters, MapState mapState) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: mapState.center ?? _defaultCenter,
        initialZoom: mapState.currentZoom,
        minZoom: 3.0,
        maxZoom: 18.0,
        onPositionChanged: (position, hasGesture) {
          _onMapPositionChanged(position.zoom);
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          maxZoom: 19,
        ),
        MarkerLayer(markers: _buildMarkers(clusters)),
      ],
    );
  }

  List<Marker> _buildMarkers(List<MapCluster> clusters) {
    return clusters.map((cluster) {
      if (cluster.isCluster) {
        return _buildClusterMarker(cluster);
      } else {
        return _buildSingleMarker(cluster.firstCampsite);
      }
    }).toList();
  }

  Marker _buildClusterMarker(MapCluster cluster) {
    return Marker(
      point: cluster.position,
      width: 60,
      height: 60,
      child: GestureDetector(
        onTap: () => _onClusterTap(cluster),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              cluster.count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Marker _buildSingleMarker(Campsite campsite) {
    return Marker(
      point: LatLng(campsite.geoLocation.lat, campsite.geoLocation.long),
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () => _onCampsiteTap(campsite),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: const Icon(
            Icons.house_outlined,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Failed to load map data',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(mapClustersProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _onMapPositionChanged(double zoom) {
    final mapState = ref.read(mapClusteringProvider);
    final campsitesAsync = ref.read(sortedCampsitesProvider);
    if (zoom != mapState.currentZoom) {
      campsitesAsync.whenData((campsites) {
        ref
            .read(mapClusteringProvider.notifier)
            .updateClusters(campsites, zoom);
      });
    }
  }

  void _onClusterTap(MapCluster cluster) {
    if (cluster.count <= 5) {
      _showClusterBottomSheet(cluster);
    } else {
      _zoomToCluster(cluster);
    }
  }

  void _onCampsiteTap(Campsite campsite) {
    context.push(
      AppRoutes.campsiteDetailRoute.replaceFirst(
        AppRoutes.idConstant,
        campsite.id,
      ),
    );
  }

  void _showClusterBottomSheet(MapCluster cluster) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.4,
            maxChildSize: 0.8,
            minChildSize: 0.3,
            builder:
                (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '${cluster.count} Campsites',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: cluster.campsites.length,
                          itemBuilder: (context, index) {
                            final campsite = cluster.campsites[index];
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  campsite.photo,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.image_not_supported,
                                        ),
                                      ),
                                ),
                              ),
                              title: Text(campsite.label.capitalize()),
                              subtitle: Text(
                                '${campsite.pricePerNight.formattedPrice()}/night',
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () {
                                Navigator.of(context).pop();
                                _onCampsiteTap(campsite);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  void _zoomToCluster(MapCluster cluster) {
    double minLat = cluster.campsites.first.geoLocation.lat;
    double maxLat = cluster.campsites.first.geoLocation.lat;
    double minLng = cluster.campsites.first.geoLocation.long;
    double maxLng = cluster.campsites.first.geoLocation.long;

    for (final campsite in cluster.campsites) {
      minLat =
          minLat < campsite.geoLocation.lat ? minLat : campsite.geoLocation.lat;
      maxLat =
          maxLat > campsite.geoLocation.lat ? maxLat : campsite.geoLocation.lat;
      minLng =
          minLng < campsite.geoLocation.long
              ? minLng
              : campsite.geoLocation.long;
      maxLng =
          maxLng > campsite.geoLocation.long
              ? maxLng
              : campsite.geoLocation.long;
    }

    _mapController.move(cluster.position, 13);
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
