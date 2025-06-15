import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';

@JsonSerializable()
class GeoLocation {
  final double lat;
  final double long;

  const GeoLocation({required this.lat, required this.long});

  ///
  /// Since i dont have any clue on where the coordinates should i decided to
  /// take this approach to better highlight the clustering.
  /// (Even though the coordinates are all place on water)
  /// - Interpreting raw values as Web Mercator (EPSG:3857) eastings/northings
  /// - Other potential fix: would be to the coordinates was to swap lat<->long
  /// and divide them by 1000. this scatter the campgrounds all over the map,
  /// no chance to show clusters of camps.
  ///
  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    final rawLat = (json['lat'] as num?)?.toDouble() ?? 0.0;
    final rawLong = (json['long'] as num?)?.toDouble() ?? 0.0;

    // Earth's radius in meters
    const R = 6378137.0;
    final x = rawLong;
    final y = rawLat;

    // Corrected Web Mercator to WGS84 conversion
    final normalizedLong = (x / R) * (180 / pi);
    final normalizedLat = (2 * atan(exp(y / R)) - pi / 2) * (180 / pi);

    /// Here is the other approach Swap and divide
    // final normalizedLat = rawLong / 1000;
    // final normalizedLong = rawLat / 1000;

    return GeoLocation(lat: normalizedLat, long: normalizedLong);
  }
}
