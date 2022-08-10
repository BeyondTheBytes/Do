import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'features/auth/wrapper.dart';
import 'features/utils/location.dart';
import 'firebase_options.dart';
import 'presentation/theme.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(App());
}

class App extends StatelessWidget {
  final routeConfig = RouteConfig();

  @override
  Widget build(BuildContext context) {
    return LocationWrapper(
      builder: (context) => AuthWrapper(
        builder: (context) => MaterialApp.router(
          title: 'Do.',
          theme: theme,
          color: theme.colorScheme.primary,
          // route
          routeInformationParser: routeConfig.routeInformationParser,
          routerDelegate: routeConfig.routerDelegate,
          backButtonDispatcher: routeConfig.backButtonDispatcher,
        ),
      ),
    );
  }
}
