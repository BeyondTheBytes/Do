import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static Future<void> load() async {
    await dotenv.load();
  }

  static String get googlePlacesKey {
    return dotenv.env['GOOGLE_PLACES_API_KEY']!;
  }
}

class Constants {
  static const proxyServer = 'legumo-proxy.herokuapp.com';
}
