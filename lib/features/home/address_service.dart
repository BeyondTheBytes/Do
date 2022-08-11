import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart';

import '../../config/constants.dart';

class AddressService {
  final googlePlace = GooglePlace(
    Env.googlePlacesKey,
    proxyUrl: kIsWeb ? Constants.proxyServer : null,
  );

  Future<List<AutocompletePrediction>> nearbyPlaces(
    Position location,
    String query,
  ) async {
    try {
      final latlong = LatLon(location.latitude, location.longitude);
      final places = await googlePlace.autocomplete.get(
        query,

        /// The origin point from which to calculate straight-line distance to
        /// the destination (returned as distance_meters). If this value is
        /// omitted, straight-line distance will not be returned.
        origin: latlong,

        radius: 50000,
        strictbounds: true,

        /// The point around which you wish to retrieve place information.
        location: latlong,
        language: 'pt',
        components: [Component('country', 'br')],
        types: 'establishment',
      );

      final predictions = places?.predictions ?? [];
      predictions.sort((left, right) =>
          (left.distanceMeters ?? 1000) - (right.distanceMeters ?? 1000));
      return predictions;
    } on Exception catch (_) {
      // TODO: add crashlytics
      rethrow;
    }
  }

  Future<String> photoUrl(
    String photoReference,
    int maxHeight,
    int maxWidth,
  ) async {
    final response =
        await googlePlace.photos.getJson(photoReference, maxHeight, maxWidth);
    return response ?? '';
  }

  Future<DetailsResult> details(String placeId) async {
    try {
      final response = await googlePlace.details.get(placeId);
      return response!.result!;
    } on Exception catch (_) {
      // TODO: add crashlytics
      rethrow;
    }
  }

  String parsePhotoUrl(String photoRef, int maxWidth, int maxHeight) {
    return 'https://maps.googleapis.com/maps/api/place/photo?photoreference=$photoRef&sensor=false&maxheight=$maxHeight&maxwidth=$maxWidth&key=${Env.googlePlacesKey}';
  }
}
