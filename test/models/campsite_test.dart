import 'package:flutter_test/flutter_test.dart';
import 'package:roadsurfer_test/models/campsite.dart';
import 'package:roadsurfer_test/models/geo_location.dart';

void main() {
  group('Campsite Model Tests', () {
    test('should create campsite from JSON', () {
      final json = {
        'id': '1',
        'label': 'test campsite',
        'photo': 'http://example.com/photo.jpg',
        'geoLocation': {'lat': 52.5200, 'long': 13.4050},
        'isCloseToWater': true,
        'isCampFireAllowed': false,
        'hostLanguages': ['en', 'de'],
        'pricePerNight': 5000.0,
        'createdAt': '2023-01-01T12:00:00.000Z',
      };

      final campsite = Campsite.fromJson(json);
      expect(campsite.id, '1');
      expect(campsite.label, 'test campsite');
      expect(campsite.isCloseToWater, true);
      expect(campsite.isCampFireAllowed, false);
      expect(campsite.hostLanguages, ['en', 'de']);
      expect(campsite.pricePerNight, 5000.0);
    });

    test('should normalize invalid coordinates', () {
      final json = {
        'id': '1',
        'label': 'test',
        'photo': 'http://example.com/photo.jpg',
        'geoLocation': {'lat': 96060.37, 'long': 72330.52},
        'isCloseToWater': true,
        'isCampFireAllowed': false,
        'hostLanguages': ['en'],
        'pricePerNight': 5000.0,
        'createdAt': '2023-01-01T12:00:00.000Z',
      };

      final campsite = Campsite.fromJson(json);

      expect(campsite.geoLocation.lat, inInclusiveRange(-90.0, 90.0));
      expect(campsite.geoLocation.long, inInclusiveRange(-180.0, 180.0));
    });
  });

  group('GeoLocation Tests', () {
    test('should normalize latitude correctly', () {
      final geoLocation = GeoLocation.fromJson({'lat': 96060.37, 'long': 0.0});
      expect(geoLocation.lat, inInclusiveRange(-90.0, 90.0));
    });

    test('should normalize longitude correctly', () {
      final geoLocation = GeoLocation.fromJson({'lat': 0.0, 'long': 72330.52});
      expect(geoLocation.long, inInclusiveRange(-180.0, 180.0));
    });
  });
}
