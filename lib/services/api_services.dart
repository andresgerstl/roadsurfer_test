import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:roadsurfer_test/models/campsite.dart';

class ApiService {
  static const String _baseUrl =
      'https://62ed0389a785760e67622eb2.mockapi.io/spots/v1';

  Future<List<Campsite>> fetchCampsites() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/campsites'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Campsite.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load campsites: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch campsites: $e');
    }
  }

  Future<Campsite> fetchCampsiteById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/campsites/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        return Campsite.fromJson(json as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load campsite $id: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch campsites: $e');
    }
  }
}
