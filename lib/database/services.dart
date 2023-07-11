import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:get_it/get_it.dart';

import '../domain/utils.dart';
import 'dataclass.dart';

final _firestore = GetIt.I.get<FirebaseFirestore>();

class EventDays {
  final List<Event> today;
  final List<Event> tomorrow;
  EventDays({required this.today, required this.tomorrow});

  bool get isEmpty => today.isEmpty && tomorrow.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

class EventsService {
  CollectionReference<Map<String, Object?>> get collection => _firestore.collection('events');

  static String _participateField(String uid) => '${DataclassesDocFields.eventParticipants}.$uid';

  Future<void> create(EventData event) => collection.doc().set(event.toJson());
  Future<void> delete(String id) => collection.doc(id).delete();
  Future<void> participate(String eventId, String uid) =>
      collection.doc(eventId).update({_participateField(uid): true});
  Future<void> unparticipate(String eventId, String uid) =>
      collection.doc(eventId).update({_participateField(uid): FieldValue.delete()});

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
    final tomorrow = DateTime(from.year, from.month, from.day).add(Duration(days: 1));
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
          (event) => event.date.compareTo(from.subtract(Duration(hours: 1))) >= 0,
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
    final databaseStream = Geoflutterfire().collectionWithConverter(collectionRef: ref).withinWithDistance(
          center: userLocation,
          radius: radius,
          field: DataclassesDocFields.eventPoint,
          strictMode: true,
          geopointFrom: (event) => EventData.fromJson(event).point.geoPoint,
        );

    return databaseStream.map(
      (docs) => docs
          .map((doc) => Event(
                event: EventData.fromJson(doc.documentSnapshot.data()!),
                id: doc.documentSnapshot.id,
              ))
          .toList(),
    );
  }

  // OTHER GETS

  Stream<List<Event>> asCreator(String uid) => collection
      .where(DataclassesDocFields.eventCreatorUid, isEqualTo: uid)
      .orderBy(DataclassesDocFields.eventDate)
      .snapshots()
      .map((e) => e.docs.map((e) => Event(event: EventData.fromJson(e.data()), id: e.id)).toList());
  Stream<List<Event>> asParticipant(String uid) =>
      collection.where(_participateField(uid), isEqualTo: true).snapshots().map((e) {
        final events = e.docs.map((e) => Event(event: EventData.fromJson(e.data()), id: e.id)).toList();
        // sorting here because otherwise it would require a
        // firestore composite index for each new user
        events.sort((left, right) => right.date.compareTo(left.date));
        return events;
      });
}

class UserConfigService {
  CollectionReference<Map<String, Object?>> get mapCollection => _firestore.collection('users');
  CollectionReference<Map<String, Object?>> get collection => mapCollection;

  Stream<UserConfig> stream(String uid) =>
      collection.doc(uid).snapshots().map((e) => e.data() != null ? UserConfig.fromJson(e.data()) : UserConfig.empty());
  Future<void> setDescription(String uid, {required String description}) => mapCollection.doc(uid).set(
        {DataclassesDocFields.userDescription: description},
        SetOptions(merge: true),
      );
  Future<void> setInterests(String uid, {required List<Sport> interests}) => mapCollection.doc(uid).set(
        {DataclassesDocFields.userSports: interests.map(sportCode).toList()},
        SetOptions(merge: true),
      );
  Future<void> setPhone(String uid, {required String phone}) => mapCollection.doc(uid).set(
        {DataclassesDocFields.userPhone: phone},
        SetOptions(merge: true),
      );
}
