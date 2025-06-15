// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campsite.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CampsiteImpl _$$CampsiteImplFromJson(Map<String, dynamic> json) =>
    _$CampsiteImpl(
      id: json['id'] as String,
      label: json['label'] as String,
      photo: json['photo'] as String,
      geoLocation: GeoLocation.fromJson(
        json['geoLocation'] as Map<String, dynamic>,
      ),
      isCloseToWater: json['isCloseToWater'] as bool,
      isCampFireAllowed: json['isCampFireAllowed'] as bool,
      hostLanguages:
          (json['hostLanguages'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      pricePerNight: (json['pricePerNight'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$CampsiteImplToJson(_$CampsiteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'photo': instance.photo,
      'geoLocation': instance.geoLocation,
      'isCloseToWater': instance.isCloseToWater,
      'isCampFireAllowed': instance.isCampFireAllowed,
      'hostLanguages': instance.hostLanguages,
      'pricePerNight': instance.pricePerNight,
      'createdAt': instance.createdAt.toIso8601String(),
    };
