import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  final Widget Function(BuildContext context) builder;
  const AuthWrapper({required this.builder});

  @override
  Widget build(BuildContext context) {
    return Provider<UserCredential?>(
      create: (_) => _UserCredential(
        _User('w5LTjnPNCbRPIY5FovbDrcMw7gj2', 'lucadillenburg'),
      ),
      builder: (context, _) => builder(context),
    );
  }
}

// TODO:

class _UserCredential extends Mock implements UserCredential {
  final _User user;
  _UserCredential(this.user);
}

class _User extends Mock implements User {
  final String uid;
  final String displayName;
  _User(this.uid, this.displayName);
}
