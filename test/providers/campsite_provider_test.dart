import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:roadsurfer_test/models/campsite.dart';
import 'package:roadsurfer_test/models/geo_location.dart';
import 'package:roadsurfer_test/providers/campsite_provider.dart';
import 'package:roadsurfer_test/services/api_services.dart';

@GenerateMocks([ApiService])
import 'campsite_provider_test.mocks.dart';

void main() {
  group('Campsite Providers', () {
    late MockApiService mockApiService;
    late ProviderContainer container;

    // Helper
    Campsite createTestCampsite({
      required String id,
      required String label,
      String photo = 'test-photo.jpg',
      double lat = 52.5200,
      double lng = 13.4050,
      bool isCloseToWater = false,
      bool isCampFireAllowed = true,
      List<String> hostLanguages = const ['EN'],
      double pricePerNight = 25.0,
    }) {
      return Campsite(
        id: id,
        label: label,
        photo: photo,
        geoLocation: GeoLocation(lat: lat, long: lng),
        isCloseToWater: isCloseToWater,
        isCampFireAllowed: isCampFireAllowed,
        hostLanguages: hostLanguages,
        pricePerNight: pricePerNight,
        createdAt: DateTime(2024, 1, 1),
      );
    }

    setUp(() {
      mockApiService = MockApiService();
      container = ProviderContainer(
        overrides: [apiServiceProvider.overrideWithValue(mockApiService)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('campsitesProvider fetches campsites', () async {
      final campsites = [
        createTestCampsite(id: '1', label: 'Camp A'),
        createTestCampsite(id: '2', label: 'Camp B'),
      ];
      when(mockApiService.fetchCampsites()).thenAnswer((_) async => campsites);

      final result = await container.read(campsitesProvider.future);

      expect(result, equals(campsites));
      verify(mockApiService.fetchCampsites()).called(1);
    });

    test('campsitesProvider handles errors', () async {
      when(mockApiService.fetchCampsites()).thenThrow(Exception('Error'));

      expect(() => container.read(campsitesProvider.future), throwsException);
    });

    test('sortedCampsitesProvider sorts campsites alphabetically', () async {
      final campsites = [
        createTestCampsite(id: '1', label: 'Camp Z'),
        createTestCampsite(id: '2', label: 'Camp B'),
        createTestCampsite(id: '3', label: 'Camp A'),
      ];
      when(mockApiService.fetchCampsites()).thenAnswer((_) async => campsites);

      await container.read(campsitesProvider.future);

      final result = container.read(sortedCampsitesProvider);

      final sortedCampsites = result.asData!.value;
      expect(sortedCampsites[0].label, 'Camp A');
      expect(sortedCampsites[1].label, 'Camp B');
      expect(sortedCampsites[2].label, 'Camp Z');
    });

    test(
      'campsiteDetailProvider returns campsite from cache when found',
      () async {
        final campsites = [
          createTestCampsite(id: '1', label: 'Camp A'),
          createTestCampsite(id: '2', label: 'Camp B'),
        ];
        when(
          mockApiService.fetchCampsites(),
        ).thenAnswer((_) async => campsites);

        final result = await container.read(campsiteDetailProvider('1').future);

        expect(result.id, '1');
        expect(result.label, 'Camp A');
        verifyNever(mockApiService.fetchCampsiteById(any));
      },
    );

    test('campsiteDetailProvider fetches from API when not in cache', () async {
      final campsites = [createTestCampsite(id: '1', label: 'Camp A')];
      final detailCampsite = createTestCampsite(
        id: '999',
        label: 'Detail Camp',
      );

      when(mockApiService.fetchCampsites()).thenAnswer((_) async => campsites);
      when(
        mockApiService.fetchCampsiteById('999'),
      ).thenAnswer((_) async => detailCampsite);

      final result = await container.read(campsiteDetailProvider('999').future);

      expect(result.id, '999');
      expect(result.label, 'Detail Camp');
      verify(mockApiService.fetchCampsiteById('999')).called(1);
    });
  });
}
