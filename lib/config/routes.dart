import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import '../features/auth/pages.dart';
import '../features/home/page.dart';
import '../features/user/page.dart';
import '../features/utils/navigation.dart';
import '../presentation/pages.dart';
import 'state.dart';

/// DEFINITIONS

class _RouterConstants {
  static const initial = '/';
  static const home = '/home';
  static const login = '/login';
  static const user = _ParameterUrl(baseUrl: '/user', pathParam: 'user');
}

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
        _RouterConstants.user.resolveUrl: (context, state, data) {
          final uid = state.pathParameters[_RouterConstants.user.pathParam];
          return BeamPage(
            title: 'User - $_title',
            key: ValueKey('user-page'),
            child: (uid == null) ? UnknownRoute() : UserPage(uid: uid),
          );
        },
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
          NavigationPage.profile: (context) =>
              UserPage(uid: AppState.auth.currentUser!.uid),
          // TODO: NOW
        },
      );
}

class AppRouter {
  final BuildContext context;
  AppRouter.of(this.context);

  void navigateLoggedOut() {
    Beamer.of(context).beamToNamed(_RouterConstants.login);
  }

  void navigateLogged() {
    Beamer.of(context)
        .beamToReplacementNamed(_RouterConstants.home, stacked: false);
  }

  void pushUserPage(String uid) {
    Beamer.of(context).beamToNamed(_RouterConstants.user.withParam(uid));
  }

  void popDialog<T extends Object?>([T? param]) {
    Navigator.of(context).pop(param);
  }
}
