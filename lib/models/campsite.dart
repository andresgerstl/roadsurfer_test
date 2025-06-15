import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:roadsurfer_test/models/geo_location.dart';
import 'package:roadsurfer_test/utils/extensions.dart';

part 'campsite.freezed.dart';
part 'campsite.g.dart';

@freezed
class Campsite with _$Campsite {
  const factory Campsite({
    required String id,
    required String label,
    required String photo,
    required GeoLocation geoLocation,
    required bool isCloseToWater,
    required bool isCampFireAllowed,
    required List<String> hostLanguages,
    required double pricePerNight,
    required DateTime createdAt,
  }) = _Campsite;

  const Campsite._();

  factory Campsite.fromJson(Map<String, dynamic> json) =>
      _$CampsiteFromJson(json);

  String get formattedPrice {
    return pricePerNight.formattedPrice();
  }

  String get languagesString => hostLanguages.join(', ').toUpperCase();
}
