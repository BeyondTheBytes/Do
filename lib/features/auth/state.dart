import 'package:firebase_auth/firebase_auth.dart';

class AuthState {
  AuthState() {
    userStream.listen((user) {
      print('xxx userStream: $user');
    });
  }

  User? get currentUser => FirebaseAuth.instance.currentUser;
  final userStream = FirebaseAuth.instance.userChanges();
}
