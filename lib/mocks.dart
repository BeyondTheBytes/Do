import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';

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
        // TODO:
        // EventData(
        //   sport: Sport.soccer,
        //   date: DateTime.now().add(Duration(hours: 2)),
        //   placeId: placeId,
        //   placeDescription: placeDescription,
        //   observations: observations,
        //   creatorUid: creatorUid,
        //   photoUrl: photoUrl,
        //   point: point,
        //   participants: participants,
        // ),
      ];

  static UserConfig userConfig() => UserConfig(
        sports: [Sport.soccer, Sport.volleyball],
        description: null,
        phone: null,
      );
}
