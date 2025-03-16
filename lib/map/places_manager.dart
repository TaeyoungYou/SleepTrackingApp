import 'package:flutter/material.dart';
import 'package:google_maps_webservice/places.dart';

const String apiKey = 'AIzaSyAykMVvYo8GjXLr_3oX_3aJZ-yMSy64NFQ';


// Data model for a place
class Place {
  final String name;
  final double latitude;
  final double longitude;

  Place({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

// @Desc     GET nearby places from Google Places API with lat, lng, and name
// @Param    latitude, longitude, radius, type, numOfPlace
Future<List<Place>> getNearbyPlaces({
  required double latitude,
  required double longitude,
  required int radius,
  String? type,
  required int numOfPlace,
}) async {
  final places = GoogleMapsPlaces(apiKey: apiKey);
  final location = Location(lat: latitude, lng: longitude);

  try {
    final result = await places.searchNearbyWithRadius(
      location,
      radius,
      type: type,
    );

    if (result.status == 'OK') {
      final limitedResults = result.results.take(numOfPlace).toList();
      return limitedResults.map((place) => Place(
        name: place.name ?? 'Unnamed',
        latitude: place.geometry?.location.lat ?? 0.0,
        longitude: place.geometry?.location.lng ?? 0.0,
      )).toList();
    } else {
      throw Exception('Places API error: ${result.errorMessage}');
    }
  } catch (e) {
    throw Exception('Failed to fetch places: $e');
  }
}

