import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../config/state.dart';

class UserProvider extends StatelessWidget {
  final Widget Function(BuildContext, User) builder;
  const UserProvider({required this.builder});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AppState.auth.userStream,
      initialData: AppState.auth.currentUser,
      builder: (context, snapshot) => builder(context, snapshot.data!),
    );
  }
}

// FORMATER

class CustomInputFormatter {
  static const phoneLength = 15;
  static TextInputFormatter get phone => MaskTextInputFormatter(
        mask: '(##) #####-####',
        filter: {"#": RegExp(r'[0-9]')},
        type: MaskAutoCompletionType.eager,
      );
  static const minNameLength = 4;
  static TextInputFormatter get name => _LowerCaseTextFormatter();
}

class _LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toLowerCase());
  }
}
