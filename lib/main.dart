import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import 'config/routes.dart';
import 'mocks.dart';
import 'presentation/theme.dart';

class AppDependencies {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;
  AppDependencies({
    required this.firebaseAuth,
    required this.firebaseFirestore,
    required this.firebaseStorage,
  });

  void injectDependencies(GetIt getIt) {
    getIt.registerSingleton<FirebaseAuth>(firebaseAuth);
    getIt.registerSingleton<FirebaseFirestore>(firebaseFirestore);
    getIt.registerSingleton<FirebaseStorage>(firebaseStorage);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await prepareApp(
    AppDependencies(
      firebaseAuth: FirebaseAuth.instance,
      firebaseFirestore: FirebaseFirestore.instance,
      firebaseStorage: FirebaseStorage.instance,
    ),
  );

  runApp(App());
}

// EXPORT

Future<void> prepareApp([AppDependencies? dependencies]) async {
  final deps = await mockDependencies();
  deps.injectDependencies(GetIt.I);

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
  );

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
