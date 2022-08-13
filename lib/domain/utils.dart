import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';

class Pair<F, S> {
  final F first;
  final S second;
  const Pair(this.first, this.second);
}

class DistanceBetween {
  static double inMeters(Position first, Position second) {
    final distanceInMeters = Geolocator.distanceBetween(
      first.latitude,
      first.longitude,
      second.latitude,
      second.longitude,
    );
    return distanceInMeters;
  }

  static double inKm(Position first, Position second) =>
      inMeters(first, second) / 1000;
}

// ////////////////////////////////////////////////////////////
// DATE
// ////////////////////////////////////////////////////////////

DateTime convertToDate(Timestamp timestamp) {
  return timestamp.toDate();
}

Timestamp convertFromDate(DateTime date) {
  return Timestamp.fromDate(date);
}

DateTime? convertToNullableDate(Timestamp? timestamp) {
  return timestamp?.toDate();
}

Timestamp? convertFromNullableDate(DateTime? date) {
  return (date == null) ? null : Timestamp.fromDate(date);
}

// ////////////////////////////////////////////////////////////
// GEOPOINT
// ////////////////////////////////////////////////////////////

GeoFirePoint convertToPoint(Map<String, Object?> map) {
  final point = map['geopoint'] as GeoPoint;
  return GeoFirePoint(point.latitude, point.longitude);
}

Map<String, Object?> convertFromPoint(GeoFirePoint point) {
  return <String, dynamic>{'geopoint': point.geoPoint, 'geohash': point.hash};
}
