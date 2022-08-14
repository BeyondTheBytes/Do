import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import '../features/auth/pages.dart';
import '../features/home/page.dart';
import '../features/user/page.dart';
import '../features/utils/navigation.dart';
import '../presentation/pages.dart';

/// DEFINITIONS

class _RouterConstants {
  static const initial = '/';
  static const home = '/home';
  static const login = '/login';
}

// ignore: unused_element
class _ParameterUrl {
  final String baseUrl;
  final String pathParam;
  const _ParameterUrl({required this.baseUrl, required this.pathParam});
  String get resolveUrl => '$baseUrl/:$pathParam';
  String withParam(String param) => '$baseUrl/$param';
}

class RouteConfig {
  static const _title = 'Do.';

  final routeInformationParser = BeamerParser();
  late final backButtonDispatcher =
      BeamerBackButtonDispatcher(delegate: routerDelegate);
  final routerDelegate = BeamerDelegate(
    locationBuilder: RoutesLocationBuilder(
      routes: {
        _RouterConstants.initial: (context, state, data) => BeamPage(
              title: _title,
              key: ValueKey('initial-page'),
              child: InitialPage(
                loggedBuilder: (context) => _signedPage(),
                unloggedBuilder: (context) => SignPage(),
              ),
            ),
        _RouterConstants.login: (context, state, data) => BeamPage(
              title: 'Entrar - $_title',
              key: ValueKey('login-page'),
              child: SignPage(),
            ),
        _RouterConstants.home: (context, state, data) => BeamPage(
              title: _title,
              key: ValueKey('home-page'),
              child: _signedPage(),
            ),
      },
    ),
    initialPath: _RouterConstants.initial,
    notFoundPage: BeamPage(
      key: ValueKey('not-found-location'),
      child: UnknownRoute(),
    ),
  );

  static Widget _signedPage() => NavigationWrapper(
        pages: {
          NavigationPage.home: (context) => HomePage(),
          NavigationPage.profile: (context) => UserPage(),
        },
      );
}

class AppRouter {
  final BuildContext context;
  AppRouter.of(this.context);

  void pushReplacementSign() {
    Beamer.of(context)
        .beamToReplacementNamed(_RouterConstants.login, stacked: false);
  }

  void pushReplacementHome() {
    Beamer.of(context)
        .beamToReplacementNamed(_RouterConstants.home, stacked: false);
  }

  void popDialog<T extends Object?>([T? param]) {
    Navigator.of(context).pop(param);
  }
}
