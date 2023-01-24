import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

final _firebaseAuth = GetIt.I.get<FirebaseAuth>();

class AuthState {
  User? get currentUser => _firebaseAuth.currentUser;
  Stream<User?> get userStream => _firebaseAuth.userChanges();
}
