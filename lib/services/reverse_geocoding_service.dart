import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Service for reverse geocoding coordinates to addresses using Nominatim
class ReverseGeocodingService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org/reverse';
  static const Duration _timeout = Duration(seconds: 10);
  
  final Dio _dio;

  ReverseGeocodingService() : _dio = Dio() {
    _dio.options.connectTimeout = _timeout;
    _dio.options.receiveTimeout = _timeout;
    _dio.options.headers = {
      'User-Agent': 'ScootUI/1.0 (LibreScoot)',
    };
  }

  /// Get address for coordinates
  /// Returns null if offline or if geocoding fails
  Future<String?> getAddress(double latitude, double longitude) async {
    try {
      debugPrint('🌍 ReverseGeocodingService: Getting address for $latitude, $longitude');
      
      final response = await _dio.get(_baseUrl, queryParameters: {
        'lat': latitude.toStringAsFixed(6),
        'lon': longitude.toStringAsFixed(6),
        'format': 'json',
        'addressdetails': '1',
        'zoom': '18',
        'accept-language': 'en-US,en',
      });

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final address = _formatAddress(data);
        debugPrint('🌍 ReverseGeocodingService: Got address: $address');
        return address;
      }
    } catch (e) {
      debugPrint('🌍 ReverseGeocodingService: Error getting address: $e');
    }
    
    return null;
  }

  /// Format address from Nominatim response
  String? _formatAddress(Map<String, dynamic> data) {
    if (data['display_name'] == null) return null;

    final addressParts = data['address'] as Map<String, dynamic>?;
    if (addressParts == null) return data['display_name'] as String?;

    final parts = <String>[];

    // Street name and number
    if (addressParts['house_number'] != null && addressParts['road'] != null) {
      parts.add('${addressParts['road']} ${addressParts['house_number']}');
    } else if (addressParts['road'] != null) {
      parts.add(addressParts['road'] as String);
    }

    // City/town/village with postal code
    final city = addressParts['city'] ?? addressParts['town'] ?? addressParts['village'];
    if (city != null) {
      if (addressParts['postcode'] != null) {
        parts.add('${addressParts['postcode']} $city');
      } else {
        parts.add(city as String);
      }
    }

    // Country
    if (addressParts['country'] != null) {
      parts.add(addressParts['country'] as String);
    }

    return parts.isEmpty ? data['display_name'] as String? : parts.join(', ');
  }

  void dispose() {
    _dio.close();
  }
}
