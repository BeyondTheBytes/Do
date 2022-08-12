import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'config/constants.dart';
import 'config/routes.dart';
import 'firebase_options.dart';
import 'presentation/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
  );
  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    Env.load(),
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
  ]);
  runApp(App());
}

class App extends StatelessWidget {
  final routeConfig = RouteConfig();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Do.',
      theme: theme,
      color: theme.colorScheme.primary,
      debugShowCheckedModeBanner: false,
      // route
      routeInformationParser: routeConfig.routeInformationParser,
      routerDelegate: routeConfig.routerDelegate,
      backButtonDispatcher: routeConfig.backButtonDispatcher,
    );
  }
}
