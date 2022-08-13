import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

import '../domain/utils.dart';
import 'dataclass.dart';

class EventDays {
  final List<Event> today;
  final List<Event> tomorrow;
  EventDays({required this.today, required this.tomorrow});

  bool get isEmpty => today.isEmpty && tomorrow.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

class EventsService {
  CollectionReference<EventData> get collection =>
      FirebaseFirestore.instance.collection('events').withConverter(
            fromFirestore: (doc, _) => EventData.fromJson(doc.data()!),
            toFirestore: (e, _) => e.toJson(),
          );

  static String _participateField(String uid) =>
      '${DataclassesDocFields.eventParticipants}.$uid';

  Future<void> create(EventData event) => collection.doc().set(event);
  Future<void> delete(String id) => collection.doc(id).delete();
  Future<void> participate(String eventId, String uid) =>
      collection.doc(eventId).update({_participateField(uid): true});
  Future<void> unparticipate(String eventId, String uid) =>
      collection.doc(eventId).update({_participateField(uid): null});

  // HOME

  Stream<EventDays> nearby(
    List<Sport> sports,
    GeoFirePoint userLocation, {
    required double radius,
    required DateTime from,
  }) {
    final databaseStream = (DateTime date) => _nearbyFromDate(
          sports,
          userLocation,
          radius: radius,
          date: formatDate(date),
        ).map((events) => _filterAndSortHomeEvents(events, date));

    final todayStream = databaseStream(from);
    final tomorrow =
        DateTime(from.year, from.month, from.day).add(Duration(days: 1));
    final tomorrowStream = databaseStream(tomorrow);

    return _join(todayStream, tomorrowStream);
  }

  static Stream<EventDays> _join(
    Stream<List<Event>> today,
    Stream<List<Event>> tomorrow,
  ) async* {
    final merged = StreamGroup.merge([
      today.map((e) => Pair(e, true)),
      tomorrow.map((e) => Pair(e, false)),
    ]);
    List<Event>? curTodayEvents = null;
    List<Event>? curTomorrowEvents = null;
    await for (final list in merged) {
      if (list.second) {
        curTodayEvents = list.first;
      } else {
        curTomorrowEvents = list.first;
      }

      if (curTodayEvents != null && curTomorrowEvents != null) {
        yield EventDays(today: curTodayEvents, tomorrow: curTomorrowEvents);
      }
    }
  }

  List<Event> _filterAndSortHomeEvents(List<Event> events, DateTime from) {
    final filteredEvents = events
        .where(
          (event) =>
              event.date.compareTo(from.subtract(Duration(hours: 1))) >= 0,
        )
        .toList();
    filteredEvents.sort((left, right) => left.date.compareTo(right.date));
    return filteredEvents;
  }

  Stream<List<Event>> _nearbyFromDate(
    List<Sport> sports,
    GeoFirePoint userLocation, {
    required double radius,
    required String date,
  }) {
    final ref = collection
        .where(
          DataclassesDocFields.eventSport,
          whereIn: sports.map(sportCode).toList(),
        )
        .where(
          DataclassesDocFields.eventDay,
          isEqualTo: date,
        );
    final databaseStream = Geoflutterfire()
        .collectionWithConverter(collectionRef: ref)
        .withinWithDistance(
          center: userLocation,
          radius: radius,
          field: DataclassesDocFields.eventPoint,
          strictMode: true,
          geopointFrom: (event) => event.point.geoPoint,
        );

    return databaseStream.map(
      (docs) => docs
          .map((doc) => Event(
                event: doc.documentSnapshot.data()!,
                id: doc.documentSnapshot.id,
              ))
          .toList(),
    );
  }

  // OTHER GETS

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

  Stream<UserConfig> stream(String uid) => collection
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
        {DataclassesDocFields.userSports: interests.map(sportCode).toList()},
        SetOptions(merge: true),
      );
  Future<void> setPhone(String uid, {required String phone}) =>
      mapCollection.doc(uid).set(
        {DataclassesDocFields.userPhone: phone},
        SetOptions(merge: true),
      );
}
