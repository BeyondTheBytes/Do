import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/structures.dart';
import '../../domain/utils.dart';
import '../../presentation/button.dart';
import '../../presentation/theme.dart';
import '../../presentation/utils.dart';

const minMetersDistanceUpdate = 100;

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
        await Geolocator.openLocationSettings();
        break;
    }
  }
}

typedef LocationResult = Either<Position, Failure>?;

class LocationWrapper extends StatefulWidget {
  final Widget Function(BuildContext context, LocationResult info) builder;
  LocationWrapper({required this.builder});

  @override
  State<LocationWrapper> createState() => _LocationWrapperState();
}

class _LocationWrapperState extends State<LocationWrapper> {
  static Position? _lastCapturedPosition;
  LocationResult? _current;
  late final StreamSubscription subscription;

  @override
  void initState() {
    subscription = Geolocator.getPositionStream().listen(
      _updatePosition,
      onError: _onError,
    );

    Geolocator.requestPermission();
    _updatePosition(_lastCapturedPosition);
    super.initState();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  void _updatePosition(Position? newPosition) {
    if (newPosition == null) return;

    final lastPosition = _current?.successOrNull;
    if (lastPosition == null ||
        DistanceBetween.inMeters(newPosition, lastPosition) >
            minMetersDistanceUpdate) {
      _lastCapturedPosition = newPosition;
      setState(() {
        _current = Either.success(newPosition);
      });
    }
  }

  void _onError(Object? error) {
    setState(() {
      _current = Either.failure(
        Failure(
          """Não conseguimos obter sua localização. Por favor, cheque as permissões do aplicativo.""",
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _current);
  }
}
