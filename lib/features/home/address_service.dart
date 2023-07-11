import 'package:geolocator/geolocator.dart';

import '../../config/constants.dart';

// Mock

class AutocompletePrediction {
  final String? placeId;
  final StructuredFormatting? structuredFormatting;
  final double? distanceMeters;
  AutocompletePrediction({this.structuredFormatting, this.placeId, this.distanceMeters});
}

class StructuredFormatting {
  final String? mainText;
  StructuredFormatting(this.mainText);
}

class DetailsResult {
  final Geometry? geometry;
  DetailsResult({this.geometry});
}

class Geometry {
  final Location? location;
  Geometry(this.location);
}

class Location {
  final double? lat;
  final double? lng;
  Location(this.lat, this.lng);
}

// Mock

class AddressService {
  Future<List<AutocompletePrediction>> nearbyPlaces(
    Position location,
    String query,
  ) async {
    return [
      AutocompletePrediction(
        placeId: 'taquaral',
        structuredFormatting: StructuredFormatting('Parque Portugal - Lagoa do Taquaral'),
      ),
      AutocompletePrediction(
        placeId: 'ibirapuera',
        structuredFormatting: StructuredFormatting('Parque Ibirapuera'),
      ),
      AutocompletePrediction(
        placeId: 'flamengo',
        structuredFormatting: StructuredFormatting('Aterro do Flamengo'),
      ),
    ];
  }

  Future<DetailsResult> details(String placeId) async {
    final loc = Location(-23.57762608717703, -46.64955920769962);
    switch (placeId) {
      case 'taquaral':
        return DetailsResult(geometry: Geometry(loc));
      case 'ibirapuera':
        return DetailsResult(geometry: Geometry(loc));
      case 'flamengo':
        return DetailsResult(geometry: Geometry(loc));
      default:
        throw Exception();
    }
  }

  String parsePhotoUrl(String photoRef, int maxWidth, int maxHeight) {
    return 'https://maps.googleapis.com/maps/api/place/photo?photoreference=$photoRef&sensor=false&maxheight=$maxHeight&maxwidth=$maxWidth&key=${Env.googlePlacesKey}';
  }
}
