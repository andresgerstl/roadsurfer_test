import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:roadsurfer_test/models/campsite.dart';

class CampsiteDetailMap extends StatelessWidget {
  const CampsiteDetailMap(this.campsite, {super.key});
  final Campsite campsite;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 300,
        child: FlutterMap(
          options: MapOptions(
            minZoom: 3.0,
            maxZoom: 18.0,
            initialCenter: LatLng(
              campsite.geoLocation.lat,
              campsite.geoLocation.long,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              maxZoom: 19,
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(
                    campsite.geoLocation.lat,
                    campsite.geoLocation.long,
                  ),
                  child: const Icon(Icons.location_pin, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
