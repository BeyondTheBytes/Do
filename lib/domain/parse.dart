import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

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
