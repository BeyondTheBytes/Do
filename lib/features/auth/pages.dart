import 'dart:async';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../config/routes.dart';
import '../../database/services.dart';
import '../../presentation/button.dart';
import '../../presentation/theme.dart';
import '../../presentation/utils.dart';
import 'service.dart';
import 'utils.dart';

final _firebaseAuth = GetIt.I.get<FirebaseAuth>();

class InitialPage extends StatelessWidget {
  final Widget Function(BuildContext) loggedBuilder;
  final Widget Function(BuildContext) unloggedBuilder;
  const InitialPage({
    required this.loggedBuilder,
    required this.unloggedBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _firebaseAuth.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppColors.of(context).darkest,
            body: Center(child: CustomLoading.forceDefaultSize()),
          );
        }

        final data = snapshot.data;
        if (data == null) {
          return unloggedBuilder(context);
        }
        return loggedBuilder(context);
      },
    );
  }
}

class SignPage extends StatefulWidget {
  @override
  State<SignPage> createState() => _SignPageState();
}

class _SignPageState extends State<SignPage> {
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _name = TextEditingController();
  final _password = TextEditingController();

  var _signUp = true;

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    _name.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const maxWidth = 600;
    final contentSize = min(MediaQuery.of(context).size.width, maxWidth);

    return DismissibleKeyboardWrapper(
      child: Scaffold(
        backgroundColor: AppColors.of(context).medium,
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                  horizontal:
                      (MediaQuery.of(context).size.width - contentSize) / 2,
                ) +
                EdgeInsets.all(25),
            child: LayoutBuilder(builder: (context, constraints) {
              final logoIcon = constraints.maxWidth * 0.35;
              return Stack(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: logoIcon * 0.7),
                    child: _buildContent(context, topPadding: logoIcon * 0.34),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.of(context).darkest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: logoIcon,
                      height: logoIcon,
                      padding: EdgeInsets.all(15),
                      child: Center(
                        child: AutoSizeText(
                          'Do.',
                          style: AppTexts.of(context)
                              .title1
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, {required double topPadding}) {
    const betweenBlocks = SizedBox(height: 30);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(),
        ],
      ),
      padding: EdgeInsets.all(35) + EdgeInsets.only(top: topPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _signUp ? 'Cadastro' : 'Entrar',
            style: AppTexts.of(context).title2,
          ),
          betweenBlocks,
          Column(
            children: <Widget>[
              TextField(
                controller: _email,
                decoration: InputDecoration(hintText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              if (_signUp) ...[
                TextField(
                  controller: _phone,
                  decoration: InputDecoration(hintText: 'Celular'),
                  inputFormatters: [CustomInputFormatter.phone],
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: _name,
                  decoration: InputDecoration(hintText: 'Nome'),
                  inputFormatters: [CustomInputFormatter.name],
                  keyboardType: TextInputType.name,
                ),
              ],
              TextField(
                controller: _password,
                decoration: InputDecoration(hintText: 'Senha'),
                obscureText: true,
              ),
            ].withBetween(SizedBox(height: 10)),
          ),
          betweenBlocks,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomButton(
                child: _signUp ? Text('Já tem conta?') : Text('Não tem conta?'),
                filled: false,
                onPressed: () {
                  setState(() {
                    _signUp = !_signUp;
                  });
                },
              ),
              CustomButton(
                child: _signUp ? Text('Cadastrar') : Text('Entrar'),
                style: AppButton.of(context).largeFilled,
                loadingText: false,
                onPressed: () => _onSign(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _onSign(BuildContext context) async {
    final emailService = EmailAuthService();
    if (_signUp) {
      if (CustomInputFormatter.phoneLength != _phone.text.length) {
        return ErrorMessage.of(context)
            .show('Digite seu o número de celular completo.');
      }
      if (_name.text.length < CustomInputFormatter.minNameLength) {
        return ErrorMessage.of(context).show(
          """O nome precisa ter mais de ${CustomInputFormatter.minNameLength} caracteres.""",
        );
      }

      final either = await emailService.signUp(
        email: _email.text,
        name: _name.text,
        password: _password.text,
      );
      await either.when<FutureOr>(
        success: (user) async {
          final configService = UserConfigService();
          await configService.setPhone(user.user!.uid, phone: _phone.text);
          AppRouter.of(context).pushReplacementHome();
        },
        failure: (failure) =>
            ErrorMessage.of(context).show(failure.description),
      );
    } else {
      final either = await emailService.signIn(
        email: _email.text,
        password: _password.text,
      );
      either.when(
        success: (user) => AppRouter.of(context).pushReplacementHome(),
        failure: (failure) =>
            ErrorMessage.of(context).show(failure.description),
      );
    }
  }
}
