import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';

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

class Assets {
  static Widget profilePicture({bool alternate = false}) => alternate
      ? SvgPicture.asset('assets/img/picture-inverted.svg')
      : SvgPicture.asset('assets/img/picture.svg');
}
