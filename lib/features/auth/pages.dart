import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../database/services.dart';
import '../../domain/utils.dart';
import '../../presentation/theme.dart';
import '../../presentation/utils.dart';
import '../../routes.dart';
import 'service.dart';
import 'utils.dart';

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
    final logoIcon = MediaQuery.of(context).size.width * 0.35;
    return DismissibleKeyboardWrapper(
      child: Scaffold(
        backgroundColor: AppColors.of(context).medium,
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(25),
              child: Stack(
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
              ),
            ),
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
              TextButton(
                child: _signUp ? Text('Já tem conta?') : Text('Não tem conta?'),
                onPressed: () {
                  setState(() {
                    _signUp = !_signUp;
                  });
                },
              ),
              OutlinedButton(
                child: _signUp ? Text('Cadastrar') : Text('Entrar'),
                style: AppButton.of(context).largeFilled,
                onPressed: () => _onSign(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _onSign(BuildContext context) async {
    if (CustomInputFormatter.phoneLength != _phone.text.length) {
      return ErrorMessage.of(context)
          .show('Digite seu o número de celular completo.');
    }
    if (_name.text.length < CustomInputFormatter.minNameLength) {
      return ErrorMessage.of(context).show(
        """O nome precisa ter mais de ${CustomInputFormatter.minNameLength} caracteres.""",
      );
    }

    final emailService = EmailAuthService();
    if (_signUp) {
      final either = await emailService.signUp(
        email: _email.text,
        name: _name.text,
        password: _password.text,
      );
      await either.when<FutureOr>(
        success: (user) async {
          final configService = UserConfigService();
          await configService.setPhone(user.user!.uid, phone: _phone.text);
          AppRouter.of(context).navigateLogged();
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
        success: (user) => AppRouter.of(context).navigateLogged(),
        failure: (failure) =>
            ErrorMessage.of(context).show(failure.description),
      );
    }
  }
}
