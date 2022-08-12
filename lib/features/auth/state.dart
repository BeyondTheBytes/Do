import 'package:firebase_auth/firebase_auth.dart';

class AuthState {
  User? get currentUser => FirebaseAuth.instance.currentUser;
  final userStream = FirebaseAuth.instance.userChanges();
}
