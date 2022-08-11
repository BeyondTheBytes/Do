import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart';
import 'package:provider/provider.dart';

import '../../database/dataclass.dart';
import '../../database/services.dart';
import '../../domain/utils.dart';
import '../../presentation/button.dart';
import '../../presentation/theme.dart';
import '../../presentation/utils.dart';
import '../utils/location.dart';
import 'address_service.dart';

enum _EventDay { today, tomorrow }

class CreateEventDialog extends StatefulWidget {
  final Function() onAdd;
  final EntryController entryController;
  const CreateEventDialog({required this.onAdd, required this.entryController});
  @override
  State<CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends State<CreateEventDialog> {
  Sport? _selectedSport = null;
  _EventDay? _selectedDay = null;
  TimeOfDay? _selectedTime = null;
  AutocompletePrediction? _selectedPlace = null;
  final _observations = TextEditingController();

  @override
  void dispose() {
    _observations.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const fieldsPadding = SizedBox(height: 10, width: 10);
    final selectedTime = _selectedTime;
    return GestureDetector(
      onTap: widget.entryController.remove,
      child: CustomDialog(
        title: 'Novo Evento',
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PlatformSelect<Sport>(
                hintText: 'Esporte',
                cupertinoDialogHeight: 230,
                cupertinoItemExtent: 45,
                itemBuilder: (context, sport) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      sportIcon(sport),
                      color: Theme.of(context).inputDecorationTheme.iconColor,
                    ),
                    SizedBox(width: 10),
                    Text(sportStr(sport).toUpperCase()),
                  ],
                ),
                items: Sport.values,
                value: _selectedSport,
                onChanged: (v) => setState(() => _selectedSport = v),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: PlatformSelect<_EventDay>(
                      hintText: 'Dia',
                      itemBuilder: (context, day) {
                        switch (day) {
                          case _EventDay.today:
                            return Text('Hoje');
                          case _EventDay.tomorrow:
                            return Text('Amanhã');
                        }
                      },
                      items: _EventDay.values,
                      value: _selectedDay,
                      onChanged: (v) => setState(() => _selectedDay = v),
                      cupertinoDialogHeight: 150,
                    ),
                  ),
                  Expanded(
                    child: CustomDropdownButton(
                      hintText: 'Horário',
                      selected: (selectedTime == null)
                          ? null
                          : Text(
                              """${selectedTime.hour}h ${selectedTime.minute}min""",
                            ),
                      onTap: () => _chooseTimeOfDay(context),
                    ),
                  ),
                ].withBetween(fieldsPadding),
              ),
              _LocalSearch(
                onSelect: (pred) {
                  setState(() => _selectedPlace = pred);
                  widget.entryController.remove();
                },
                entryController: widget.entryController,
                selected: _selectedPlace,
              ),
              TextField(
                controller: _observations,
                decoration: InputDecoration(hintText: 'Observações'),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: CustomButton(
                  child: Text('Criar Evento'),
                  style: AppButton.of(context).largeFilled,
                  stretch: false,
                  loadingText: false,
                  onPressed: _createEvent,
                ),
              ),
            ].withBetween(fieldsPadding),
          ),
        ),
      ),
    );
  }

  // CLICKS

  void _chooseTimeOfDay(BuildContext context) async {
    if (Platform.isIOS) {
      showCupertinoSelect<void>(
        context: context,
        builder: (context) => Container(
          height: 250,
          child: CupertinoTimerPicker(
            mode: CupertinoTimerPickerMode.hm,
            minuteInterval: 5,
            onTimerDurationChanged: (newDuration) {
              final timeOfDay = TimeOfDay(
                  hour: newDuration.inHours,
                  minute: newDuration.inMinutes % 60);
              setState(() => _selectedTime = timeOfDay);
            },
          ),
        ),
      );
    } else {
      final timeOfDay = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        initialEntryMode: TimePickerEntryMode.input,
      );
      if (timeOfDay != null) {
        setState(() => _selectedTime = timeOfDay);
      }
    }
  }

  Future<void> _createEvent() async {
    widget.entryController.remove();

    final day = _selectedDay;
    final time = _selectedTime;
    final place = _selectedPlace;
    final sport = _selectedSport;
    if (day == null || time == null || place == null || sport == null) {
      return ErrorMessage.of(context)
          .show('Por favor, preencha todos os campos.');
    }

    final placeId = place.placeId;
    if (placeId == null) {
      return ErrorMessage.of(context)
          .show('Por favor, digite o endereço completo.');
    }

    final now = DateTime.now();
    final todayTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    late final DateTime dateTime;
    switch (day) {
      case _EventDay.today:
        dateTime = todayTime;
        break;
      case _EventDay.tomorrow:
        dateTime = todayTime.add(Duration(hours: Duration.hoursPerDay));
        break;
    }
    if (dateTime.compareTo(DateTime.now()) < 0) {
      return ErrorMessage.of(context)
          .show('Por favor, escolha um horário futuro.');
    }

    final addressService = AddressService();
    final placesDetails = await addressService.details(placeId);

    final images = imagesSport(sport);
    final image = images[Random().nextInt(images.length)];

    final event = EventData(
      creatorUid: context.read<UserCredential?>()!.user!.uid,
      date: dateTime,
      observations: _observations.text,
      participants: null,
      placeId: placeId,
      sport: sport,
      placeDescription: place.structuredFormatting!.mainText!,
      photoUrl: image,
      point: GeoFirePoint(
        placesDetails.geometry!.location!.lat!,
        placesDetails.geometry!.location!.lng!,
      ),
    );

    final events = EventsService();
    await events.create(event);

    widget.onAdd();
  }
}

class _LocalSearch extends StatelessWidget {
  final Function(AutocompletePrediction) onSelect;
  final AutocompletePrediction? selected;
  final EntryController entryController;
  _LocalSearch({
    required this.onSelect,
    required this.selected,
    required this.entryController,
  });

  final addressService = AddressService();

  @override
  Widget build(BuildContext context) {
    final locationResult = context.watch<LocationResult>();
    final selected = this.selected;
    return locationResult.when(
      failure: (failure) => LocationPermissionCard(failure: failure),
      success: (location) {
        final text = (selected == null)
            ? null
            : selected.structuredFormatting!.mainText!;
        return TextField(
          controller: TextEditingController(text: text),
          decoration: InputDecoration(hintText: 'Local'),
          onChanged: (v) => onChanged(context, v, location),
        );
      },
    );
  }

  void onChanged(BuildContext context, String value, Position location) async {
    if (value.isEmpty) return;
    final predictions = await addressService.nearbyPlaces(location, value);
    _showNewPredictions(context, predictions);
  }

  void _showNewPredictions(
    BuildContext context,
    List<AutocompletePrediction> predictions,
  ) {
    entryController.remove();

    if (predictions.isEmpty) return;

    final searchRenderbox = context.findRenderObject() as RenderBox;
    final searchOffset = searchRenderbox.localToGlobal(Offset.zero);

    final newEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: searchOffset.dy + searchRenderbox.size.height - 6,
        left: searchOffset.dx,
        child: Container(
          width: searchRenderbox.size.width,
          child: _buildPredictions(context, predictions),
        ),
      ),
    );
    entryController.insert(context, newEntry);
  }

  Widget _buildPredictions(
    BuildContext context,
    List<AutocompletePrediction> predictions,
  ) {
    return Material(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[400]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              blurRadius: 3,
              spreadRadius: -1,
              offset: Offset(0, 5),
            )
          ],
        ),
        child: Column(
          children: predictions
              .map((prediction) => itemBuilder(context, prediction))
              .withBetween(Container(height: 1, color: Colors.grey[400]))
              .toList(),
        ),
      ),
    );
  }

  Widget itemBuilder(BuildContext context, AutocompletePrediction prediction) {
    return GestureDetector(
      onTap: () => onSelect(prediction),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        width: double.infinity,
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: Text(
                prediction.structuredFormatting!.mainText!,
                maxLines: 2,
                style: AppTexts.of(context).body1.copyWith(color: Colors.black),
              ),
            ),
            if (prediction.distanceMeters != null)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  '${(prediction.distanceMeters! / 1000).floor()} km',
                  style: AppTexts.of(context)
                      .body1
                      .copyWith(color: Colors.grey[800], fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
