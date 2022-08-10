import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'dataclass.dart';

class EventsService {
  CollectionReference<EventData> get collection =>
      FirebaseFirestore.instance.collection('events').withConverter(
            fromFirestore: (doc, _) => EventData.fromJson(doc.data()!),
            toFirestore: (e, _) => e.toJson(),
          );

  static String _participateField(String uid) =>
      '${DataclassesDocFields.eventParticipants}.$uid';
  static Event _parseSavedEvent(QueryDocumentSnapshot<EventData> e) =>
      Event(event: e.data(), id: e.id);

  Future<void> create(EventData event) => collection.doc().set(event);
  Future<void> participate(String eventId, String uid) =>
      collection.doc(eventId).update({_participateField(uid): true});

  final geo = Geoflutterfire();
  Stream<List<Event>> nearby(
    List<Sport> sports,
    GeoFirePoint userLocation, {
    required double radius,
  }) {
    final ref = collection.where(
      DataclassesDocFields.eventSport,
      whereIn: sports.map(sportToStr).toList(),
    );
    return geo
        .collectionWithConverter(collectionRef: ref)
        .withinWithDistance(
          center: userLocation,
          radius: radius,
          field: DataclassesDocFields.eventPoint,
          strictMode: true,
          geopointFrom: (event) => event.point.geoPoint,
        )
        .map((e) => e
            .map((e) => Event(
                  event: e.documentSnapshot.data()!,
                  id: e.documentSnapshot.id,
                ))
            .toList());
  }

  Stream<List<Event>> asCreator(String uid) => collection
      .where(DataclassesDocFields.eventCreatorUid, isEqualTo: uid)
      .snapshots()
      .map((e) => e.docs.map((e) => Event(event: e.data(), id: e.id)).toList());
  Stream<List<Event>> asParticipant(String uid) => collection
      .where(_participateField(uid), isEqualTo: true)
      .snapshots()
      .map((e) => e.docs.map((e) => Event(event: e.data(), id: e.id)).toList());
}

class UserConfigService {
  CollectionReference<Map<String, Object?>> get mapCollection =>
      FirebaseFirestore.instance.collection('users');
  CollectionReference<UserConfig> get collection => mapCollection.withConverter(
        fromFirestore: (doc, _) => UserConfig.fromJson(doc.data()),
        toFirestore: (e, _) => e.toJson(),
      );

  Stream<UserConfig> config(String uid) => collection
      .doc(uid)
      .snapshots()
      .map((e) => e.data() ?? UserConfig.empty());
  Future<void> setDescription(String uid, {required String description}) =>
      mapCollection.doc(uid).set(
        {DataclassesDocFields.userDescription: description},
        SetOptions(merge: true),
      );
  Future<void> setInterests(String uid, {required List<Sport> interests}) =>
      mapCollection.doc(uid).set(
        {DataclassesDocFields.userSports: interests},
        SetOptions(merge: true),
      );
}