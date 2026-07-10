import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:latlong2/latlong.dart';

/// Wraps OpenRouteService Directions API (free, no billing required).
/// Docs: https://openrouteservice.org/dev/#/api-docs/v2/directions/{profile}/get
class RoutingService {
  static const _baseUrl = 'https://api.openrouteservice.org/v2';

  /// Returns a list of [LatLng] waypoints for the driving route between
  /// [origin] and [destination].
  ///
  /// Falls back to a straight line if ORS is unreachable.
  static Future<List<LatLng>> getDrivingRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final apiKey = dotenv.get('OPENROUTESERVICE_API_KEY');
      if (apiKey.isEmpty) throw Exception('ORS key not configured');

      final dio = Dio();
      final response = await dio.get(
        '$_baseUrl/directions/driving-car',
        queryParameters: {
          'start': '${origin.longitude},${origin.latitude}',
          'end': '${destination.longitude},${destination.latitude}',
        },
        options: Options(
          headers: {'Authorization': apiKey},
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final coords = response.data['features'][0]['geometry']['coordinates']
            as List<dynamic>;
        return coords
            .map((c) => LatLng(
                  (c[1] as num).toDouble(),
                  (c[0] as num).toDouble(),
                ))
            .toList();
      }
    } catch (e) {
      // Log and fall back gracefully
      // ignore: avoid_print
      print('[RoutingService] ORS error: $e');
    }

    // Fallback: straight line between origin and destination
    return [origin, destination];
  }

  /// Geocode an address string to [LatLng] using Nominatim (OSM, free).
  /// Returns null if the address could not be resolved.
  static Future<LatLng?> geocodeAddress(String address) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': address,
          'format': 'json',
          'limit': 1,
        },
        options: Options(
          headers: {'User-Agent': 'SafeSphere/1.0 (lumora; contact@safesphere.app)'},
          receiveTimeout: const Duration(seconds: 8),
        ),
      );

      if (response.statusCode == 200 && (response.data as List).isNotEmpty) {
        final place = response.data[0];
        return LatLng(
          double.parse(place['lat'] as String),
          double.parse(place['lon'] as String),
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('[RoutingService] Nominatim error: $e');
    }
    return null;
  }

  /// Reverse-geocode [LatLng] to a human-readable address string.
  static Future<String?> reverseGeocode(LatLng point) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': point.latitude,
          'lon': point.longitude,
          'format': 'json',
        },
        options: Options(
          headers: {'User-Agent': 'SafeSphere/1.0 (lumora; contact@safesphere.app)'},
          receiveTimeout: const Duration(seconds: 8),
        ),
      );

      if (response.statusCode == 200) {
        return response.data['display_name'] as String?;
      }
    } catch (e) {
      // ignore: avoid_print
      print('[RoutingService] Reverse geocode error: $e');
    }
    return null;
  }
}
