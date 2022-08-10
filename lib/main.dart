import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'presentation/theme.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      // route
      routeInformationParser: routeConfig.routeInformationParser,
      routerDelegate: routeConfig.routerDelegate,
      backButtonDispatcher: routeConfig.backButtonDispatcher,
    );
  }
}
