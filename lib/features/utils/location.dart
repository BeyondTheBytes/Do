import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/structures.dart';
import '../../presentation/button.dart';
import '../../presentation/utils.dart';

Future<void> requestPermission(
  BuildContext context, {
  required Function() onAccept,
}) async {
  final permission = await Geolocator.requestPermission();
  switch (permission) {
    case LocationPermission.always:
    case LocationPermission.whileInUse:
    case LocationPermission.unableToDetermine:
      onAccept();
      break;
    case LocationPermission.denied:
    case LocationPermission.deniedForever:
      await Geolocator.openLocationSettings();
      break;
  }
}

class LocationPermissionCard extends StatelessWidget {
  final Failure failure;
  final Function() onAccept;
  final Color? foregroundColor;
  const LocationPermissionCard({
    required this.failure,
    required this.onAccept,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final foregroundColor = this.foregroundColor;
    return IconErrorWidget(
      icon: Icon(
        FontAwesomeIcons.triangleExclamation,
        color: foregroundColor ?? Colors.grey[300],
        size: IconErrorWidget.iconSize,
      ),
      title: 'Habilite a Localização',
      description:
          """Precisamos da sua localização para encontrarmos eventos perto de você.""",
      style: TextStyle(color: foregroundColor),
      button: CustomButton(
        child: Text('Habilitar'),
        filled: true,
        stretch: false,
        onPressed: () => requestPermission(context, onAccept: onAccept),
      ),
    );
  }
}

typedef LocationResult = Either<Position, Failure>?;

class LocationWrapper extends StatelessWidget {
  final Widget Function(BuildContext context, LocationResult info) builder;
  LocationWrapper({required this.builder});

  static const _errorMessage =
      """Não conseguimos obter sua localização. Por favor, cheque as permissões do aplicativo.""";

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Position>(
      future: Geolocator.getCurrentPosition(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return builder(
            context,
            Either.failure(Failure(_errorMessage)),
          );
        }

        final newPosition = snapshot.data;
        return builder(
          context,
          newPosition == null ? null : Either.success(newPosition),
        );
      },
    );
  }
}
