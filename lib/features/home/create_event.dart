import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../database/dataclass.dart';
import '../../domain/utils.dart';
import '../../presentation/button.dart';
import '../../presentation/theme.dart';
import '../../presentation/utils.dart';

enum _EventDay { today, tomorrow }

class CreateEventDialog extends StatefulWidget {
  final Function() onAdd;
  const CreateEventDialog({required this.onAdd});
  @override
  State<CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends State<CreateEventDialog> {
  Sport? _selectedSport = null;
  _EventDay? _selectedDay = null;
  TimeOfDay? _selectedTime = null;
  final _place = TextEditingController();
  final _observations = TextEditingController();

  @override
  void dispose() {
    _place.dispose();
    _observations.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const fieldsPadding = SizedBox(height: 10, width: 10);
    final selectedTime = _selectedTime;
    return CustomDialog(
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
            TextField(
              controller: _place,
              decoration: InputDecoration(hintText: 'Local'),
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
    // TODO:
    widget.onAdd();
  }
}
