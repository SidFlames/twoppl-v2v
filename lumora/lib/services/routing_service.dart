import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:latlong2/latlong.dart';

class RouteData {
  final List<LatLng> geometry;
  final double distanceMeters;
  final double durationSeconds;

  RouteData({
    required this.geometry,
    required this.distanceMeters,
    required this.durationSeconds,
  });
}

class Suggestion {
  final String displayName;
  final double latitude;
  final double longitude;

  Suggestion({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });
}

/// Wraps OpenRouteService Directions API (free, no billing required).
/// Docs: https://openrouteservice.org/dev/#/api-docs/v2/directions/{profile}/get
class RoutingService {
  static const _baseUrl = 'https://api.openrouteservice.org/v2';

  /// Returns [RouteData] waypoints + summary for the driving route between
  /// [origin] and [destination].
  ///
  /// Falls back to a straight line if ORS is unreachable.
  static Future<RouteData> getDrivingRoute({
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
        final feature = response.data['features'][0];
        final coords = feature['geometry']['coordinates'] as List<dynamic>;
        final summary = feature['properties']['summary'] ?? {};
        
        final geometry = coords
            .map((c) => LatLng(
                  (c[1] as num).toDouble(),
                  (c[0] as num).toDouble(),
                ))
            .toList();

        return RouteData(
          geometry: geometry,
          distanceMeters: (summary['distance'] as num?)?.toDouble() ?? 0.0,
          durationSeconds: (summary['duration'] as num?)?.toDouble() ?? 0.0,
        );
      }
    } catch (e) {
      // Log and fall back gracefully
      // ignore: avoid_print
      print('[RoutingService] ORS error: $e');
    }

    // Fallback: straight line between origin and destination
    return RouteData(
      geometry: [origin, destination],
      distanceMeters: 1000.0,
      durationSeconds: 300.0,
    );
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

  /// Fetch autofill suggestions as the user types from Nominatim.
  static Future<List<Suggestion>> getSuggestions(String query) async {
    if (query.trim().length < 3) return [];
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'limit': 5,
          'addressdetails': 1,
        },
        options: Options(
          headers: {'User-Agent': 'SafeSphere/1.0 (lumora; contact@safesphere.app)'},
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200) {
        final results = response.data as List<dynamic>;
        return results.map((item) {
          return Suggestion(
            displayName: item['display_name'] as String,
            latitude: double.parse(item['lat'] as String),
            longitude: double.parse(item['lon'] as String),
          );
        }).toList();
      }
    } catch (e) {
      // ignore: avoid_print
      print('[RoutingService] Suggestions error: $e');
    }
    return [];
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
