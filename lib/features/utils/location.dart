import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/structures.dart';
import '../../domain/utils.dart';
import '../../presentation/button.dart';
import '../../presentation/utils.dart';

class LocationPermissionCard extends StatelessWidget {
  final Failure failure;
  final Function() onAccept;
  const LocationPermissionCard({required this.failure, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return IconErrorWidget(
      icon: Icon(
        FontAwesomeIcons.triangleExclamation,
        color: Colors.grey[300],
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
        onAccept();
        break;
      case LocationPermission.denied:
      case LocationPermission.deniedForever:
        await Geolocator.openLocationSettings();
        break;
    }
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
