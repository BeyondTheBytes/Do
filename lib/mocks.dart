import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

import 'database/dataclass.dart';
import 'main.dart';

Future<AppDependencies> mockDependencies() async {
  final user = MockUser(
    isAnonymous: false,
    uid: 'mock_uid',
    email: 'caiosantos@gmail.com',
    displayName: 'caiosantos',
    photoURL:
        'https://images.unsplash.com/photo-1639747279286-c07eecb47a0b?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1287&q=80',
    metadata: UserMetadata(
      DateTime.now().subtract(Duration(days: 38)).millisecondsSinceEpoch,
      DateTime.now().millisecondsSinceEpoch,
    ),
  );

  final deps = AppDependencies(
    firebaseFirestore: FakeFirebaseFirestore(),
    firebaseAuth: MockFirebaseAuth(mockUser: user, signedIn: true),
    firebaseStorage: MockFirebaseStorage(),
  );

  final eventsCollection = deps.firebaseFirestore.collection('events');
  for (final event in Mocks.events()) {
    await eventsCollection.add(event.toJson());
  }

  final usersCollection = deps.firebaseFirestore.collection('users');
  await usersCollection.doc('mock_uid').set(Mocks.userConfig().toJson());

  return deps;
}

class Mocks {
  static List<EventData> events() => [
        // OLD as participant
        event(
          sport: Sport.soccer,
          nowDiff: -Duration(days: 4, hours: 2),
          amountParticipants: 23,
          creatorUid: 'mock_uid',
          isParticipant: true,
          imageIndex: 0,
        ),
        event(
          sport: Sport.soccer,
          nowDiff: -Duration(days: 9, hours: 5),
          amountParticipants: 11,
          isParticipant: true,
          imageIndex: 1,
        ),
        // NEW to participate
        event(
          sport: Sport.volleyball,
          nowDiff: Duration(hours: 2),
          isParticipant: false,
          imageIndex: 0,
          amountParticipants: 17,
        ),
        event(
          sport: Sport.volleyball,
          nowDiff: Duration(hours: 4),
          isParticipant: false,
          imageIndex: 1,
          amountParticipants: 11,
        ),
        event(
          sport: Sport.soccer,
          nowDiff: Duration(hours: 1, minutes: 30),
          isParticipant: false,
          imageIndex: 2,
          amountParticipants: 23,
        ),
        event(
          sport: Sport.soccer,
          nowDiff: Duration(hours: 3, minutes: 30),
          isParticipant: false,
          imageIndex: 3,
          amountParticipants: 14,
        ),
        event(
          sport: Sport.soccer,
          nowDiff: Duration(hours: 5, minutes: 30),
          isParticipant: false,
          imageIndex: 4,
          amountParticipants: 7,
        ),
      ];

  static EventData event({
    required Duration nowDiff,
    required int amountParticipants,
    required bool isParticipant,
    Sport sport = Sport.soccer,
    int imageIndex = 0,
    String creatorUid = 'user2',
  }) {
    final participants = <String, bool>{};
    if (isParticipant) participants['mock_uid'] = true;
    for (var i = 0; i < amountParticipants; i++) {
      participants['user${i + 1}'] = true;
    }

    return EventData(
      sport: sport,
      date: DateTime.now().add(nowDiff),
      placeId: 'ChIJ0RGdBvFZzpQRQeWcrwlhk8s',
      placeDescription: 'Parque Ibirapuera',
      observations: '',
      creatorUid: creatorUid,
      photoUrl: imagesSport(sport)[imageIndex],
      point: GeoFirePoint(-23.587245094679023, -46.659524072456016),
      participants: participants,
    );
  }

  static UserConfig userConfig() => UserConfig(
        sports: [Sport.soccer, Sport.volleyball],
        description: null,
        phone: null,
      );
}
