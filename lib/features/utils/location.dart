import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../domain/structures.dart';
import '../../presentation/button.dart';
import '../../presentation/theme.dart';
import '../../presentation/utils.dart';

class LocationPermissionCard extends StatelessWidget {
  final Failure failure;
  const LocationPermissionCard({required this.failure});

  @override
  Widget build(BuildContext context) {
    return IconErrorWidget(
      icon: Icon(
        FontAwesomeIcons.triangleExclamation,
        color: AppColors.of(context).warning,
        size: IconErrorWidget.iconSize,
      ),
      title: 'Habilite a Localização',
      description:
          """Precisamos da sua localização para encontrarmos eventos perto de você.""",
      button: CustomButton(
        child: Text('Habilitar'),
        filled: true,
        stretch: false,
        onPressed: () => _requestPermission(context),
      ),
    );
  }

  Future<void> _requestPermission(BuildContext context) async {
    final permission = await Geolocator.requestPermission();
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
      case LocationPermission.unableToDetermine:
        break;
      case LocationPermission.denied:
      case LocationPermission.deniedForever:
        await Geolocator.openAppSettings();
        break;
    }
  }
}

typedef LocationResult = Either<Position, Failure>;

class LocationWrapper extends StatelessWidget {
  final Widget Function(BuildContext context) builder;
  const LocationWrapper({required this.builder});

  @override
  Widget build(BuildContext context) {
    // TODO:
    return Provider<LocationResult>(
      create: (_) => Either.success(Position(
        latitude: 0,
        longitude: 0,
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        timestamp: null,
        floor: 0,
        isMocked: false,
      )),
      builder: (context, _) => builder(context),
    );
  }
}
